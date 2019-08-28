#!/bin/sh
#################################################
###  基础表:       部门基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_department_info.sh. &
###  结果目标:      model.basic_department_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir    basic_department_info

HIVE_DB=model
HIVE_TABLE=basic_department_info
TARGET_TABLE=basic_department_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "
	    CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            code STRING COMMENT '部门代码',
            name STRING COMMENT '部门名称',
            level STRING COMMENT '部门级别',
            parent_code STRING COMMENT '父级部门代码',
            parent_name STRING COMMENT '父级部门名称',
            status STRING COMMENT '状态码,0:可用,1:不可用',
            type STRING COMMENT '类型码,0:教学部门,1:非教学部门',
            person_type STRING COMMENT '人员类型（1工勤人员2专职任教3行政人员4教辅人员5科研机构人员99其他附属机构人员）',
            is_innovation_entrepreneurship STRING COMMENT '是否创新创业试点系(0:否 1：是)'
        )
        COMMENT '部门基础信息表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建表--部门基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}
#创建临时表 - 组织机构信息表
#    TABLE_COLUMNS="department_code STRING comment '部门代码',
#                  department_name STRING comment '部门名称',
#                  department_type STRING comment '部门类型代码 1:教学单位 2：非教学单位',
#                  parents_code STRING comment '上级代码',
#                  degree STRING comment '层级 如一级部门，二级部门',
#                  create_time TIMESTAMP COMMENT '创建时间'"
function create_pm_org_department_info(){
    hive -e "DROP TABLE IF EXISTS tmp.pm_org_department_info;"
    hive -e " create table tmp.pm_org_department_info as
                    SELECT
                      DISTINCT '01' as department_code,
                      '党群部门' as department_name,
                      '2' as department_type,
                      '12510' as parents_code,
                      '1' as degree,
                      '0' as sfcxcy,
                      from_unixtime(
                        unix_timestamp(),
                        'yyyy-MM-dd HH:mm:ss'
                      ) AS create_time
                    UNION ALL
                    SELECT
                      DISTINCT '02' as department_code,
                      '教学部门' as department_name,
                      '1' as department_type,
                      '12510' as parents_code,
                      '1' as degree,
                      '0' as sfcxcy,
                      from_unixtime(
                        unix_timestamp(),
                        'yyyy-MM-dd HH:mm:ss'
                      ) AS create_time
                    UNION ALL
                    SELECT
                      DISTINCT '03' as department_code,
                      '行管部门' as department_name,
                      '2' as department_type,
                      '12510' as parents_code,
                      '1' as degree,
                      '0' as sfcxcy,
                      from_unixtime(
                        unix_timestamp(),
                        'yyyy-MM-dd HH:mm:ss'
                      ) AS create_time
                    UNION ALL
                    select
                      a.dwdm as department_code,
                      a.dwmc as department_name,
                      case when a.by1 = '党群部门' then '2' when a.by1 = '教学部门' then '1' when a.by1 = '行管部门' then '2' else null end as department_type,
                      case when a.by1 = '党群部门' then '01' when a.by1 = '教学部门' then '02' when a.by1 = '行管部门' then '03' else null end as parents_code,
                      '2' as degree,
                      case when a.sfcxcyx='否' then 0  when a.sfcxcyx='是' then 1 end sfcxcy,
                      from_unixtime(
                        unix_timestamp(),
                        'yyyy-MM-dd HH:mm:ss'
                      ) AS create_time
                    FROM
                      raw.pm_t_xx_dw a
                    WHERE
                      length(a.dwdm)= 4
                    UNION ALL
                    select
                      a.dwdm as department_code,
                      a.dwmc as department_name,
                      case when a.by1 = '党群部门' then '2' when a.by1 = '教学部门' then '1' when a.by1 = '行管部门' then '2' else null end as department_type,
                      a.LSDWDM as parents_code,
                      '3' as degree,
                      case when a.sfcxcyx='否' then 0  when a.sfcxcyx='是' then 1 end sfcxcy,
                      from_unixtime(
                        unix_timestamp(),
                        'yyyy-MM-dd HH:mm:ss'
                      ) AS create_time
                    FROM
                      raw.pm_t_xx_dw a
                    WHERE
                      length(a.dwdm)> 4
                "
}


function import_table(){
   create_pm_org_department_info
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                      a.department_code as code,
                      a.department_name as name,
                      case when a.department_code = '12510' then '0' else a.degree end  as level,
                      case when b.department_code is null then ' ' else b.department_code end  as parent_code,
                      case when b.department_name is null then ' ' else b.department_name end  as parent_name,
                      '0' as status,
                      case when a.department_name like '%学院%' and a.department_code!='12510'  then  '0'
                           else '1' end as type,
                      case
                         when a.department_name like '%学院%' then '4'
                         when a.department_name like '%科研%' then '5'
                         when a.department_name like '%人事%' then '3'
                         when a.department_name like '%后勤%' then '1'
                      else '99' end as person_type,
                     a.sfcxcy as is_innovation_entrepreneurship
                    from
                      tmp.pm_org_department_info a
					  left join tmp.pm_org_department_info b
					  on a.parents_code =b.department_code
    "
    fn_log "导入数据--部门基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,level,parent_code,parent_name,status,type,person_type,is_innovation_entrepreneurship"

    fn_log "导出数据--部门基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish

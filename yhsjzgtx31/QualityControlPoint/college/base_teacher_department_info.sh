#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir base_teacher_department_info

HIVE_DB=assurance
HIVE_TABLE=base_teacher_department_info
TARGET_TABLE=base_teacher_department_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                department_no String COMMENT '部门编号',
                department_name String COMMENT '部门名称',
                department_level String COMMENT '部门级别 1级  2级  3级 4级  等等',
                parent_code String COMMENT '父级部门编号',
                parent_name String COMMENT '父级部门名称',
                department_status String COMMENT '部门状态 NORMAL 正常  LOCK 锁定',
                department_type String COMMENT '部门类型  JXBM  教学部门  ZNBM 职能部门',
                person_type String COMMENT '人员类型 GQRY 工勤人员 ZZJS 专职任教 XZRY 行政人员  FDRY 教辅人员  KYJGRY 科研机构人员 QT其他附属机构人员',
                create_time String COMMENT '创建时间 格式：YYYY-MM-DD HH:mm:ss'
    ) COMMENT '教职工归属部门信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——教职工归属部门信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            SELECT
              b.department_no,
              b.department_name,
              b.department_level,
              b.parent_code,
              b.parent_name,
              b.department_status,
              b.department_type,
              b.person_type,
              b.create_time
            FROM
              (
                select
                  distinct a.code as department_no,
                  a.name as department_name,
                  a.level as department_level,
                  a.parent_code as parent_code,
                  a.parent_name as parent_name,
                  case when a.status = '0' then 'NORMAL' else 'LOCK' end as department_status,
                  case when a.type = '0' then 'JXBM' else 'ZNBM' end as department_type,
                  case when a.person_type = '1' then 'GQRY' when a.person_type = '2' then 'ZZJS' when a.person_type = '3' then 'XZRY' when a.person_type = '4' then 'FDRY' when a.person_type = '5' then 'KYJGRY' else 'QT' end as person_type,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                from
                  model.basic_department_info a
              ) b
            "
    fn_log "导入数据 —— 教职工归属部门信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'department_no,department_name,department_level,parent_code,parent_name,department_status,department_type,person_type,create_time'

    fn_log "导出数据--教职工归属部门信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish

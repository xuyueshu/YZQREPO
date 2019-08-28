#!/bin/sh
#################################################
###  基础表:       课程基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_course_info.sh. &
###  结果目标:      model.basic_course_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_course_info

HIVE_DB=model
HIVE_TABLE=basic_course_info
TARGET_TABLE=basic_course_info
PRE_YEAR=`date +%Y`
SEMESTER_YEAR=$((${PRE_YEAR} - 1))"-"${PRE_YEAR}
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "
	    CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	        code STRING COMMENT '课程代码',
            name STRING COMMENT '课程名称',
            en_name STRING COMMENT '课程英文名称',
            credit DECIMAL(2,1) COMMENT '学分',
            week_hour DECIMAL(6,1) COMMENT '周学时(平均周学时)',
            total_hour DECIMAL(6,1) COMMENT '总学时',
            theory_hour DECIMAL(6,1) COMMENT '理论学时',
            practice_hour DECIMAL(6,1) COMMENT '实践学时',
            computer_hour DECIMAL(6,1) COMMENT '上机学时',
            other_hour DECIMAL(6,1) COMMENT '其他学时',
            intro STRING COMMENT '课程简介',
            unit STRING COMMENT '开设单位',
            type STRING COMMENT '课程类别',
            open_year STRING COMMENT '开课年月',
            teacher_code STRING COMMENT '负责人编号',
            teacher_name STRING COMMENT '负责人姓名'
        )
        COMMENT '课程基础信息表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

   fn_log "创建表--课程基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
                    select
                    distinct
                    a.kcbh as code,
                    a.kcmc as name,
                    'kc' as en_name,
                    cast(a.xf as DECIMAL(2,1))  as credit,
                    cast(a.zxs as DECIMAL(6,1)) as week_hour,
                    cast(a.ztxs as DECIMAL(6,1)) as total_hour,
                    cast(a.llxs as DECIMAL(6,1)) as theory_hour,
                    cast(a.sjxs as DECIMAL(6,1)) as practice_hour,
                    '' as computer_hour,
                    '' as other_hour,
                    a.kcjj as intro,
                    a.KKYBMC as unit,
                    a.kclx as type,
                    substr(a.XKKH,2,9)as open_year,
                    a.rkjsbh as teacher_code,
                    a.rkjsxm as teacher_name
                    from
                    raw.sw_T_ZG_KCXXB a
                    where  substr(a.XKKH,2,9)= '${SEMESTER_YEAR}'

    "
    fn_log "导入数据--课程基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,en_name,credit,week_hour,total_hour,theory_hour,practice_hour,computer_hour,other_hour,intro,unit,type,open_year,teacher_code,teacher_name"

    fn_log "导出数据--课程基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish
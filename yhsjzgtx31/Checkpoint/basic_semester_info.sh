#!/bin/sh
#################################################
###  基础表:       学期基础信息表
###  维护人:       王浩
###  数据源:       自行整理

###  导入方式:      全量
###  运行命令:      sh basic_semester_info.sh. &
###  结果目标:      app.basic_semester_info
#################################################
cd `dirname $0`
source ./config.sh
exec_dir basic_semester_info

HIVE_DB=app
HIVE_TABLE=base_school_calendar_info
TARGET_TABLE=base_school_calendar_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            semester_year STRING COMMENT '学年',
            semester STRING COMMENT '学期',
            begin_time STRING COMMENT '开始时间',
            end_time STRING COMMENT '结束时间',
            sort STRING COMMENT '排序,开始时间倒序排列'
      )COMMENT '学期基础信息表'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--学期基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

    ###################################################
    ###加载本地数据
    ###################################################

    hive -e "LOAD DATA LOCAL INPATH 'basic_semester_info.csv' INTO TABLE ${HIVE_DB}.${HIVE_TABLE};"

    fn_log "加载本地数据到"

    hive -e "INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        SELECT
        semester_year,
        substr(semester,0,1) as semester,
        substr(begin_time,0,19) begin_time,
        substr(end_time,0,19) end_time,
        row_number() over(order by begin_time desc ) sort
        FROM ${HIVE_DB}.${HIVE_TABLE}
        WHERE from_unixtime(unix_timestamp(),'yyyy-MM-dd') > begin_time"

    fn_log "导入数据--学期基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by ',' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "semester_year,semester,begin_time,end_time,sort"

    fn_log "导出数据--学期基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish
#!/bin/sh
cd `dirname $0`
source ././../config.sh
exec_dir base_major_info

HIVE_DB=assurance
HIVE_TABLE=base_major_info
TARGET_TABLE=base_major_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            major_code String COMMENT '专业代码',
            major_name String COMMENT '专业名称',
            create_time String COMMENT '创建时间 格式：YYYY-MM-DD HH:mm:ss'
    ) COMMENT '专业基本信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——专业基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                distinct
                a.code as major_code,
                a.name as major_name,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from model.basic_semester_major a
    "
    fn_log "导入数据 —— 专业基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'major_code,major_name,create_time'

    fn_log "导出数据--专业基本信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish

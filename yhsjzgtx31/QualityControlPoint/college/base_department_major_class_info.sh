#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir base_department_major_class_info

HIVE_DB=assurance
HIVE_TABLE=base_department_major_class_info
TARGET_TABLE=base_department_major_class_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                department_no String COMMENT '系编号',
                department_name String COMMENT '系名称',
                major_no String COMMENT '专业编号',
                major_name String COMMENT '专业名称',
                class_no String COMMENT '班级编号',
                class_name String COMMENT '班级名称',
                create_time String COMMENT '创建时间 格式：YYYY-MM-DD HH:mm:ss'
    ) COMMENT '系部专业班级关联信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——系部专业班级关联信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                distinct
                a.academy_code as department_no,
                a.academy_name as department_name,
                a.major_code as major_no,
                a.major_name as major_name,
                a.code as class_no,
                a.name as class_name,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_class_info a
    "
    fn_log "导入数据 —— 系部专业班级关联信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'department_no,department_name,major_no,major_name,class_no,class_name,create_time'

    fn_log "导出数据--系部专业班级关联信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish

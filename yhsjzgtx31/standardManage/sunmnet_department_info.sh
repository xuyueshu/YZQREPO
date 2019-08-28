#!/bin/sh
cd `dirname $0`
source ./config.sh
exec_dir sunmnet_department_info

HIVE_DB=standardManage
HIVE_TABLE=sunmnet_department_info
TARGET_TABLE=sunmnet_department_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                department_no String COMMENT '部门编号唯一标识',
                department_type String COMMENT '部门类别（数据字典维护保存field_key）',
                manager_no String COMMENT '负责人编号',
                manager_name String COMMENT '负责人名称',
                parent_no String COMMENT '上级部门编号',
                department_name String COMMENT '部门名称',
                department_describe String COMMENT '部门描述',
                department_status String COMMENT '部门状态    正常 NORMAL,  锁定 LOCK',
                create_time String COMMENT '创建时间  格式：YYYYMMDDHHmmssSSS',
                modify_no String COMMENT '修改人编号',
                modify_name String COMMENT '修改人姓名',
                last_modify_time String COMMENT '最后修改时间  格式：YYYYMMDDHHmmssSSS'
    ) COMMENT '部门信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——部门信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            SELECT
              b.code department_no,
              case when b.type = '0' then 'JXBM' else 'ZNBM' end as department_type,
              '' manager_no,
              '' manager_name,
              b.parent_code parent_no,
              b.name department_name,
              b.name department_describe,
              case when b.status=0 then 'NORMAL' else 'LOCK' end department_status,
              from_unixtime(unix_timestamp(),'yyyyMMddHHmmssSSS') create_time,
              'A1526379359484' modify_no,
              'leo' modify_name,
              from_unixtime(unix_timestamp(),'yyyyMMddHHmmssSSS') last_modify_time
            FROM model.basic_department_info b
            "
    fn_log "导入数据 —— 部门信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'department_no,department_type,manager_no,manager_name,parent_no,department_name,department_describe,department_status,create_time,modify_no,modify_name,last_modify_time'

    fn_log "导出数据--教职工归属部门信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish

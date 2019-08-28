#!/bin/sh
cd `dirname $0`
source ./config.sh
exec_dir sunmnet_user_info

HIVE_DB=standardManage
HIVE_TABLE=sunmnet_user_info
TARGET_TABLE=sunmnet_user_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                user_no  String comment '用户编号',
                user_name String comment '用户姓名',
                user_nickname  String comment '用户昵称',
                user_mobile String comment '用户手机号',
                department_no String comment '部门编号',
                user_mail String comment '用户邮箱',
                user_status String comment '用户状态   初始化INIT， 正常 NORMAL,  锁定 LOCK',
                user_password String comment '用户密码	 （密文）',
                relation_type String comment '关联类型（数据字典维护保存field_key）',
                relation_no String comment '关联编号  老师和校长的唯一编号',
                create_time String comment '创建时间  格式：YYYYMMDDHHmmssSSS',
                modify_no String comment '修改人编号',
                modify_name String comment '修改人姓名',
                last_modify_time String comment '最后修改时间  格式：YYYYMMDDHHmmssSSS'
    ) COMMENT '用户信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——用户信息表：${HIVE_DB}.${HIVE_TABLE}"
}
#user_password 123456
function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                    c.user_no,
                    c.user_name,
                    c.user_nickname,
                    c.user_mobile ,
                    c.department_no ,
                    c.user_mail ,
                    c.user_status,
                    c.user_password ,
                    c.relation_type ,
                    c.relation_no,
                    c.create_time,
                    c.modify_no,
                    c.modify_name,
                    c.last_modify_time
                FROM
                  (
                    SELECT
                        row_number() OVER(
                           PARTITION BY a.code
                           ORDER BY
                           substr(a.semester_year, 1, 4) DESC
                        ) as num,
                        concat('U',unix_timestamp(),a.code) user_no,
                        a.name user_name,
                        '' user_nickname,
                        '' user_mobile ,
                        a.first_dept_code department_no ,
                        '' user_mail ,
                        'NORMAL' user_status,
                        'e10adc3949ba59abbe56e057f20f883e' user_password ,
                        'TEACHER' relation_type ,
                        a.code relation_no,
                        from_unixtime(unix_timestamp(),'yyyyMMddHHmmssSSS') create_time,
                        'A1526379359484' modify_no,
                        'leo' modify_name,
                        from_unixtime(unix_timestamp(),'yyyyMMddHHmmssSSS') last_modify_time
                    FROM model.basic_teacher_info a
                  ) c
                where c.num = 1
    "
    fn_log "导入数据 —— 用户信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'user_no,user_name,user_nickname,user_mobile,department_no,user_mail,user_status,user_password,relation_type,relation_no,create_time,modify_no,modify_name,last_modify_time'

    fn_log "导出数据--用户信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish

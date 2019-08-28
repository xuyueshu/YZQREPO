#!/bin/sh
###################################################
###   基础表:      学生夜不归宿信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_pull_tonight

HIVE_DB=model
HIVE_TABLE=student_pull_tonight
TARGET_TABLE=student_pull_tonight

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              academy_code      STRING    COMMENT '系部编号',
              major_code      STRING    COMMENT '专业编号',
              class_code      STRING    COMMENT '班级编号',
              code      STRING    COMMENT '学生编号',
              name      STRING    COMMENT '学生姓名',
              time      STRING    COMMENT '夜不归宿时间(yyyy-mm-dd)',
              semester_year      STRING    COMMENT '学年',
              semester      STRING    COMMENT '学期'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生夜不归宿信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}

function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
        a.XYDM as academy_code,
        a.ZYDM as major_code,
        a.BJDM as class_code,
        a.XH as code,
        a.xm as name,
        a.WJSJ as time,
        a.XN as semester_year,
        a.XQ as semester
        from
        raw.sw_T_ZG_XG_WJCFB a
        where a.wjsjjg like '%夜不归宿%'
        "
        fn_log " 导入数据--学生夜不归宿信息表:${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
--table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
--input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
--null-string '\\N' --null-non-string '\\N'  \
--columns "academy_code,major_code,class_code,code,name,time,semester_year,semester"

fn_log "导出数据--学生夜不归宿信息表:${HIVE_DB}.${TARGET_TABLE}"

}

#init_exit
create_table
import_table
#export_table
finish
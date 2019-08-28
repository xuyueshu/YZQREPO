#!/bin/sh
###################################################
###   基础表:      学生考勤信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_attendance_info.sh &
###  结果目标:      model.student_attendance_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_attendance_info

HIVE_DB=model
HIVE_TABLE=student_attendance_info
TARGET_TABLE=student_attendance_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '系部编号',
                                        major_code   STRING     COMMENT '专业编号',
                                        class_code   STRING     COMMENT '班级编号',
                                        code   STRING     COMMENT '学生编号',
                                        lesson_number   STRING     COMMENT '上课班级号(课序号)',
                                        course   STRING     COMMENT '课程编号',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期'        )COMMENT  '学生考勤信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生考勤信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}"
        fn_log " 导入数据--学生考勤信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,code,lesson_number,course,semester_year,semester"

    fn_log "导出数据--学生考勤信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
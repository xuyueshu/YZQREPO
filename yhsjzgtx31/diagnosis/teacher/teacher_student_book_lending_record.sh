#!/bin/sh
###################################################
###   基础表:      图书借阅明细
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_student_book_lending_record.sh &
###  结果目标:      app.teacher_student_book_lending_record
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_student_book_lending_record

HIVE_DB=model
HIVE_TABLE=teacher_student_book_lending_record
TARGET_TABLE=teacher_student_book_lending_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号或学生编号',
                                        name   STRING     COMMENT '姓名',
                                        semester   STRING     COMMENT '学期',
                                        semester_year   STRING     COMMENT '学年',
                                        book_name   STRING     COMMENT '图书名称',
                                        book_type   STRING     COMMENT '图书类别',
                                        book_code   STRING     COMMENT '图书编号',
                                        lending_time   STRING     COMMENT '借阅时间',
                                        code_type   STRING     COMMENT '1学生，2老师'        )COMMENT  '图书借阅明细'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--图书借阅明细: ${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester,semester_year,book_name,book_type,book_code,lending_time,code_type"

    fn_log "导出数据--图书借阅明细: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
export_table
finish
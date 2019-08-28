#!/bin/sh
###################################################
###   基础表:      学生一卡通消费表
###   维护人:      ZhangWeiCe
###   数据源:      model.basic_ecard_consume_record,model.basic_student_info

###  导入方式:      全量导入
###  运行命令:      sh student_one_card.sh &
###  结果目标:      app.student_one_card
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_one_card

HIVE_DB=app
HIVE_TABLE=student_one_card
TARGET_TABLE=student_one_card

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        academy_code   STRING     COMMENT '系部编号',
                        major_code   STRING     COMMENT '专业编号',
                        class_code   STRING     COMMENT '班级编号',
                        code   STRING     COMMENT '学号',
                        money   STRING     COMMENT '消费金额',
                        semester_year   STRING     COMMENT '学年',
                        semester   STRING     COMMENT '学期')COMMENT  '学生一卡通消费表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生一卡通消费表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            t2.academy_code as academy_code,
            t2.major_code as major_code,
            t2.class_code as class_code,
            t1.code as code,
            t1.fee as money,
            t1.semester_year as semester_year,
            t1.semester as semester
        from model.basic_ecard_consume_record t1
        left join model.basic_student_info t2 on t1.code=t2.code
        "
        fn_log " 导入数据--学生一卡通消费表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,code,money,semester_year,semester"

    fn_log "导出数据--学生一卡通消费表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
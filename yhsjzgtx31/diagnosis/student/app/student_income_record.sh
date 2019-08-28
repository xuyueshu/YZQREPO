#!/bin/sh
###################################################
###   基础表:      学生就业收入统计
###   维护人:      ZhangWeiCe
###   数据源:      model.student_job_orientation

###  导入方式:      全量导入
###  运行命令:      sh student_income_record.sh &
###  结果目标:      app.student_income_record
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_income_record

HIVE_DB=app
HIVE_TABLE=student_income_record
TARGET_TABLE=student_income_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                            code   STRING     COMMENT '学生编号',
                            semester_year   STRING     COMMENT '学年',
                            amount   STRING     COMMENT '薪资金额',
                            employment_post   STRING     COMMENT '就业企业',
                            company_type   STRING     COMMENT '企业性质  HZ：合资，DZ：独资，GY：国有 ，SY：私营 ,QT : 其他'        )COMMENT  '学生就业收入统计'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生就业收入统计: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            code,
            semester_year,
            cast(case when pay_money=' ' then 0.0 end as decimal(9,2)) as amount,
            nvl(company_name,'') as employment_post,
            company_type
        from model.student_job_orientation
        "
        fn_log " 导入数据--学生就业收入统计: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,semester_year,amount,employment_post,company_type"

    fn_log "导出数据--学生就业收入统计: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
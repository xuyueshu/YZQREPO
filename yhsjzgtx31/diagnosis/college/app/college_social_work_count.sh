#!/bin/sh
###################################################
###   基础表:      学院社会服务统计表
###   维护人:      yangsh
###   数据源:      model.donation_record

###  导入方式:      全量导入
###  运行命令:      sh college_social_work_count.sh &
###  结果目标:      app.college_social_work_count
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir college_social_work_count

HIVE_DB=app
HIVE_TABLE=college_social_work_count
TARGET_TABLE=college_social_work_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        project_sum_num   STRING     COMMENT '项目数量',
                                        project_sum_money   STRING     COMMENT '项目到款额',
                                        semester_year   STRING     COMMENT '学年'
                                        )COMMENT  '学院社会服务统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院社会服务统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
                select count(code) as project_sum_num,
                sum(arrival_account_money) as project_sum_money,
                semester_year
                from model.scientific_project_funds_info
                group by semester_year
        "
        fn_log " 导入数据--学院社会服务统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "project_sum_num,project_sum_money,semester_year"

    fn_log "导出数据--学院社会服务统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
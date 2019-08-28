#!/bin/sh
###################################################
###   基础表:      专业科研情况统计表
###   维护人:      ZhangWeiCe
###   数据源:      model.scientific_project_basic_info,model.scientific_project_funds_info,model.basic_teacher_info

###  导入方式:      全量导入
###  运行命令:      sh major_scientific_info.sh &
###  结果目标:      app.major_scientific_info
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_scientific_info

HIVE_DB=app
HIVE_TABLE=major_scientific_info
TARGET_TABLE=major_scientific_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        academy_code   STRING     COMMENT '系部编号',
                        major_code   STRING     COMMENT '专业编号',
                        transverse_project_num   STRING     COMMENT '横向项目数量',
                        transverse_amount   STRING     COMMENT '横向项目到款额(万元)',
                        semester_year   STRING     COMMENT '学年',
                        major_name   STRING     COMMENT '专业名称',
                        academy_name   STRING     COMMENT '系部名称',
                        portrait_project_num   STRING     COMMENT '纵向项目数量',
                        portrait_amount   STRING     COMMENT '纵向项目到款额(万元)')COMMENT  '专业科研情况统计表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业科研情况统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            nvl(t3.academy_code,'') AS academy_code,
            nvl(t3.major_code,'') AS major_code,
            SUM(case when t1.project_nature=1 then 1 else 0 end) as transverse_project_num,
            round(SUM(case when t1.project_nature=1 then nvl(t2.arrival_account_money,0) else 0 end)/10000,4) as transverse_amount,
            t1.semester_year as semester_year,
            nvl(t3.major_name,'') AS major_name,
            nvl(t3.academy_name,'') AS academy_name,
            SUM(case when t1.project_nature=2 then 1 else 0 end) as portrait_project_num,
            round(SUM(case when t1.project_nature=2 then t2.arrival_account_money else 0 end)/10000,4) as portrait_amount
        from model.scientific_project_basic_info t1
        left join model.scientific_project_funds_info t2 on t1.code=t2.code
        left join model.basic_teacher_info t3 on t1.teacher_code=t3.code
        GROUP BY t3.academy_code,t3.major_code,t3.major_name,t3.academy_name,t1.semester_year
        "
        fn_log " 导入数据--专业科研情况统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,transverse_project_num,transverse_amount,semester_year,major_name,academy_name,portrait_project_num,portrait_amount"

    fn_log "导出数据--专业科研情况统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
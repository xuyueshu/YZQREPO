#!/bin/sh
###################################################
###   基础表:      课程各个指标达标情况表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh course_kpi_standard_state.sh &
###  结果目标:      model.course_kpi_standard_state
###################################################
#数据不支持
cd `dirname $0`
source ../../config.sh
exec_dir course_kpi_standard_state

HIVE_DB=model
HIVE_TABLE=course_kpi_standard_state
TARGET_TABLE=course_kpi_standard_state

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        course_code   STRING     COMMENT '课程编号',
                                        course_name   STRING     COMMENT '课程名称',
                                        academy_code   STRING     COMMENT '系部代码',
                                        academy_name   STRING     COMMENT '系部名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称',
                                        total_hour   STRING     COMMENT '课时',
                                        is_pro   STRING     COMMENT '是否精品课程0否1是',
                                        standard_num   STRING     COMMENT '达标项数',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        teaching_plan   STRING     COMMENT '教学计划：是，否',
                                        teaching_text   STRING     COMMENT '授课教案：是，否',
                                        course_standard   STRING     COMMENT '课程标准：是，否'        )COMMENT  '课程各个指标达标情况表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--课程各个指标达标情况表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
        a.KCBH as course_code,
        a.KCMC as course_name,
        a.KKYBBH as academy_code,
        a.KKYBMC as academy_name,
        a.SYZYDM as major_code,
        a.SYZY as major_name,
        a.ztxs as total_hour,
        ' ' as is_pro,
        ' ' as standard_num,
        as semester_year,
        as semester,
        as teaching_plan,
        as teaching_text,
        as course_standard
        from
        raw.sw_T_ZG_KCXXB a


        "
        fn_log " 导入数据--课程各个指标达标情况表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "course_code,course_name,academy_code,academy_name,major_code,major_name,total_hour,is_pro,standard_num,semester_year,semester,teaching_plan,teaching_text,course_standard"

    fn_log "导出数据--课程各个指标达标情况表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
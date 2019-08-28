#!/bin/sh
###################################################
###   基础表:      专业考试通过率
###   维护人:      ZhangWeiCe
###   数据源:       app.student_summary_achievements_count,model.basic_major_info

###  导入方式:      全量导入
###  运行命令:      sh major_examination_rate.sh &
###  结果目标:      app.major_examination_rate
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_examination_rate

HIVE_DB=app
HIVE_TABLE=major_examination_rate
TARGET_TABLE=major_examination_rate

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        major_code   STRING     COMMENT '专业编号',
                        major_name   STRING     COMMENT '专业名称',
                        academy_code   STRING     COMMENT '院系编号',
                        academy_name   STRING     COMMENT '院系名称',
                        course_code   STRING     COMMENT '课程编号',
                        course_name   STRING     COMMENT '课程名称',
                        good_ratio   STRING     COMMENT '考试优秀率',
                        pass_rate   STRING     COMMENT '考试通过率',
                        fail_rate   STRING     COMMENT '考试不及格率',
                        semester_year   STRING     COMMENT '学年',
                        semester   STRING     COMMENT '学期')COMMENT  '专业考试通过率'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业考试通过率: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT DISTINCT
            t1.major_code AS major_code,
            t2.NAME AS major_name,
            t1.academy_code AS academy_code,
            t2.academy_name AS academy_name,
            t1.course_code AS course_code,
            t1.course_name AS course_name,
            ROUND((t1.excellent_num/t1.num)*100,2) AS good_ratio,
            ROUND((t1.qualified_num/t1.num)*100,2) AS pass_rate,
            ROUND((t1.no_qualified_num/t1.num)*100,2) AS fail_rate,
            t1.semester_year AS semester_year,
            t1.semester AS semester
        FROM
            app.student_summary_achievements_count t1
            LEFT JOIN model.basic_major_info t2 ON t1.major_code = t2.CODE
        "
        fn_log " 导入数据--专业考试通过率: ${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "major_code,major_name,academy_code,academy_name,course_code,course_name,good_ratio,pass_rate,fail_rate,semester_year,semester"

    fn_log "导出数据--专业考试通过率: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
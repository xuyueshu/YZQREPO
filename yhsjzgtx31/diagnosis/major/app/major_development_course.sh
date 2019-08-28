#!/bin/sh
###################################################
###   基础表:      联合开发课程
###   维护人:      ZhangWeiCe
###   数据源:      model.basic_textbook_info

###  导入方式:      全量导入
###  运行命令:      sh major_development_course.sh &
###  结果目标:      app.major_development_course
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_development_course

HIVE_DB=app
HIVE_TABLE=major_development_course
TARGET_TABLE=major_development_course

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        dept_code   STRING     COMMENT '系部代码',
                        dept_name   STRING     COMMENT '系部名称',
                        major_code   STRING     COMMENT '专业代码',
                        major_name   STRING     COMMENT '专业名称',
                        material_count   STRING     COMMENT '联合开发教材数',
                        course_count   STRING     COMMENT '联合开发课程数',
                        semester_year   STRING     COMMENT '学年')COMMENT  '联合开发课程'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--联合开发课程: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            t1.academy_code AS dept_code,
            t1.academy_name AS dept_name,
            t1.major_code AS major_code,
            t1.major_name AS major_name,
            t1.material_count AS material_count,
            t2.course_count AS course_count,
            t1.semester_year AS semester_year
        FROM
        ( SELECT
            academy_code,
            academy_name,
            major_code,
            major_name,
            textbook_code,
            count( 1 ) AS material_count,
            semester_year
            FROM
                model.basic_textbook_info
            WHERE
                is_enterprise_cooperation = 1
            GROUP BY
                academy_code,
                academy_name,
                major_code,
                major_name,
                textbook_code,
                semester_year
             ) t1 left join
             (SELECT
                academy_code,
                academy_name,
                major_code,
                major_name,
                course_code,
                count( 1 ) AS course_count,
                semester_year
            FROM
                model.basic_textbook_info
            WHERE
                is_enterprise_cooperation = 1
            GROUP BY
                academy_code,
                academy_name,
                major_code,
                major_name,
                course_code,
                semester_year
            ) t2 on t1.major_code=t2.major_code and t1.semester_year=t2.semester_year
        "
        fn_log " 导入数据--联合开发课程: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "dept_code,dept_name,major_code,major_name,material_count,course_count,semester_year"

    fn_log "导出数据--联合开发课程: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
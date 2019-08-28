#!/bin/sh
###################################################
###   基础表:      专业精品在线课程信息表
###   维护人:      ZhangWeiCe
###   数据源:      model.course_resource

###  导入方式:      全量导入
###  运行命令:      sh major_goods_online_course.sh &
###  结果目标:      app.major_goods_online_course
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_goods_online_course

HIVE_DB=app
HIVE_TABLE=major_goods_online_course
TARGET_TABLE=major_goods_online_course

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                            major_code   STRING     COMMENT '专业编号',
                            major_name   STRING     COMMENT '专业名称',
                            academy_code   STRING     COMMENT '学院编号',
                            academy_name   STRING     COMMENT '院系名称',
                            national_online_course_count   STRING     COMMENT '国家级在线课程总数',
                            provincial_online_course_count   STRING     COMMENT '省级在线课程总数',
                            college_onlie_course_count   STRING     COMMENT '院级在线课程总数',
                            online_course_count   STRING     COMMENT '在线课程总数',
                            course_count   STRING     COMMENT '课程总数',
                            semester   STRING     COMMENT '学期:(1第一学期，2第二学期)',
                            semester_year   STRING     COMMENT '学年')COMMENT  '专业精品在线课程信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业精品在线课程信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            t1.major_code,
            t1.major_name,
            t1.academy_code,
            t1.academy_name,
            SUM( case when t1.level=1 and t1.online_num=1 then 1 else 0 end ) AS national_online_course_count,
            SUM( case when t1.level=2 and t1.online_num=1 then 1 else 0 end ) AS provincial_online_course_count,
            SUM( case when t1.level=3 and t1.online_num=1 then 1 else 0 end ) AS college_onlie_course_count,
            SUM( case when t1.online_num=1 then 1 else 0 end ) AS online_course_count,
            count(1) AS course_count,
            t1.semester AS semester,
            t1.semester_year AS semester_year
        FROM model.course_resource t1
        GROUP BY t1.major_code,t1.major_name,t1.academy_code,t1.academy_name,t1.semester,t1.semester_year
        "
        fn_log " 导入数据--专业精品在线课程信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "major_code,major_name,academy_code,academy_name,national_online_course_count,provincial_online_course_count,college_onlie_course_count,online_course_count,course_count,semester,semester_year"

    fn_log "导出数据--专业精品在线课程信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
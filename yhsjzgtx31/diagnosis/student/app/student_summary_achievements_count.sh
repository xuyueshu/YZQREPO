#!/bin/sh
#################################################
###  基础表:       学生各科成绩概况统计表
###  维护人:       王浩
###  数据源:       model.student_score_record,model.basic_student_info

###  导入方式:      全量导入
###  运行命令:      sh student_summary_achievements_count.sh. &
###  结果目标:      app.student_summary_achievements_count
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir student_summary_achievements_count

HIVE_DB=app
HIVE_TABLE=student_summary_achievements_count
TARGET_TABLE=student_summary_achievements_count

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
        academy_code STRING COMMENT '系编号',
        major_code STRING COMMENT '专业编号',
        class_code STRING COMMENT '班级编号',
        course_name STRING COMMENT '课程名称',
        course_code STRING COMMENT '课程编号',
        num INT COMMENT '考试总人数',
        excellent_num INT COMMENT '优秀人数',
        good_num  INT COMMENT'良好人数',
        medium_num INT COMMENT '中等人数',
        qualified_num INT COMMENT '合格人数',
        no_qualified_num INT COMMENT '不合格人数',
        semester STRING COMMENT '学期',
        semester_year STRING  COMMENT '学年',
           academy_name STRING  COMMENT '系名称',
        major_name STRING  COMMENT '专业名称',
        class_name STRING  COMMENT '班级名称'
    ) COMMENT '学生各科成绩概况统计表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表 ——学生各科成绩概况统计表：${HIVE_DB}.${HIVE_TABLE}"
}
#不往mysql里面导 专业名称/班级名称
function import_table() {
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
            academy_code as academy_code,
            major_code as major_code,
            class_code as class_code,
            course_name as course_name,
            course_code as course_code,
            count(*) as num,
            SUM(IF(score>= 90 , 1, 0)) as excellent_num,
            SUM(IF(score< 90 and 75<=score, 1, 0)) as good_num,
            SUM(IF(score< 75 and 60<=score, 1, 0)) as medium_num,
            SUM(IF(score> 60, 1, 0)) as qualified_num,
            SUM(IF(score< 60, 1, 0)) as no_qualified_num,
            semester as semester,
            semester_year as semester_year,
            academy_name as academy_name,
            major_name as major_name,
            class_name as class_name
            from
            (
            select a.code,b.name,b.academy_code,b.academy_name,b.major_code,b.major_name,b.class_code,b.class_name,a.semester_year,a.semester,a.score,a.course_code,a.course_name
            FROM model.student_score_record a left join model.basic_student_info b on a.code=b.code
            ) a
            group by academy_code,academy_name,major_name,major_code,class_code,course_name
            course_code,semester,semester_year;"
    fn_log "导入数据 —— 学生各科成绩概况统计表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'academy_code,major_code,class_code,course_name,course_code,num,excellent_num,good_num,medium_num,qualified_num,no_qualified_num,semester,semester_year'

    fn_log "导出数据--}学生各科成绩概况统计表${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish

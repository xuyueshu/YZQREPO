#!/bin/sh
#################################################
###  基础表:       学生各科成绩概况明细表
###  维护人:       王浩
###  数据源:       model.student_score_record,model.basic_student_info

###  导入方式:      全量导入
###  运行命令:      sh student_summary_achievements_record.sh. &
###  结果目标:      app.student_summary_achievements_record
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir student_summary_achievements_record

HIVE_DB=app
HIVE_TABLE=student_summary_achievements_record
TARGET_TABLE=student_summary_achievements_record

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
        course_name STRING COMMENT '课程名称',
        course_code STRING COMMENT '课程编号',
        excellent_num STRING COMMENT '平均分',
        semester STRING COMMENT '学期',
        semester_year STRING COMMENT '学年',
        class_code STRING COMMENT '班级编号',
        major_code STRING COMMENT '专业编号',
        type INT COMMENT '类型（1:专业 2:班级）'
    ) COMMENT '学生各科成绩概况明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表--学生各科成绩概况明细表：${HIVE_DB}.${HIVE_TABLE}"

}

function import_table() {
    hive -e "
        create table tmp.student_behavior_score as
            select
            course_name as course_name,
            course_code as course_code,
            avg(score) as excellent_num,
            semester as semester,
            semester_year as semester_year,
            '' as class_code,
            major_code as major_code,
            '1' as  type
            from
            (
            select distinct  a.code,b.name,b.academy_code,b.major_code,b.class_code,a.semester_year,a.semester,a.score,a.course_code,a.course_name
            FROM model.student_score_record a left join model.basic_student_info b on a.code=b.code  where b.name is not null
            )a
            group by course_name,course_code,semester,semester_year,major_code
            union all
             select
            course_name as course_name,
            course_code as course_code,
            avg(score) as excellent_num,
            semester as semester,
            semester_year as semester_year,
            class_code as class_code,
            major_code as major_code,
            '2' as  type
            from
            (
            select distinct a.code,b.name,b.academy_code,b.major_code,b.class_code,a.semester_year,a.semester,a.score,a.course_code,a.course_name
            FROM model.student_score_record a left join model.basic_student_info b on a.code=b.code  where b.name is not null
            )a
            group by course_name,course_code,semester,semester_year,major_code,class_code;
        "
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
            course_name,course_code,excellent_num,semester,semester_year,nvl(class_code,' '),nvl(major_code,' '),type
            from tmp.student_behavior_score
    "
    hive -e "
         DROP TABLE IF EXISTS tmp.student_behavior_score;
    "

    fn_log "导入数据--学生各科成绩概况明细表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'course_name,course_code,excellent_num,semester,semester_year,class_code,major_code,type'

    fn_log "导出数据--学生各科成绩概况明细表 ${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish

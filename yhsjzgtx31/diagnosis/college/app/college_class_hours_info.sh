#!/bin/sh
###################################################
###   基础表:      学院课时情况
###   维护人:      yangsh
###   数据源:      model.teacher_course_info, model.basic_teacher_info

###  导入方式:      全量导入
###  运行命令:      sh college_class_hours_info.sh &
###  结果目标:      app.college_class_hours_info
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir college_class_hours_info

HIVE_DB=app
HIVE_TABLE=college_class_hours_info
TARGET_TABLE=college_class_hours_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        per_capita_hours   STRING     COMMENT '人均课时',
                                        per_teacher_hours   STRING     COMMENT '专任教师人均课时',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期'
                                        )COMMENT  '学院课时情况'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院课时情况: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
       select
       aa.per_teacher_hours as per_capita_hours,
       bb.per_teacher_hours as per_teacher_hours,
       aa.semester_year,
       aa.semester from (
                    select sum(cast(teaching_hours as decimal(5,2))+cast(experiment_hours as decimal(5,2))+cast(computer_hours as decimal(5,2))+cast(other_hours as decimal(5,2)))/count(code) as per_teacher_hours,
                    semester_year,semester
                    from model.teacher_course_info group by semester_year,semester
                    ) aa left join (
                    select  sum(cast(teaching_hours as decimal(5,2))+cast(experiment_hours as decimal(5,2))+cast(computer_hours as decimal(5,2))+cast(other_hours as decimal(5,2)))/count(a.code) as per_teacher_hours,
                    a.semester_year,a.semester from model.teacher_course_info a inner join (select code,semester_year from model.basic_teacher_info where teacher_type='校内专任教师') b  on a.code=b.code and a.semester_year=b.semester_year
                    group by a.semester_year,a.semester
                    ) bb on aa.semester_year=bb.semester_year and aa.semester=bb.semester
        "
        fn_log " 导入数据--学院课时情况: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "per_capita_hours,per_teacher_hours,semester_year,semester"

    fn_log "导出数据--学院课时情况: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
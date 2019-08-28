#!/bin/sh
##########################################################
###  基础表:       教师带课表
###  维护人:       shilp
###  数据源:       model.teacher_course_info,model.teacher_change_class,app.basic_semester_student_info,model.teacher_class_info

###  导入方式:      全量
###  运行命令:      sh teacher_lessons_info.sh. &
###  结果目标:      app.teacher_lessons_info
##########################################################
cd `dirname $0`
source ../../../config.sh
exec_dir teacher_lessons_info

HIVE_DB=app
HIVE_TABLE=teacher_lessons_info
TARGET_TABLE=teacher_lessons_info

function create_table(){
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
        code STRING COMMENT '教师编码',
        name STRING COMMENT '教师姓名',
        semester_year STRING COMMENT '学年',
        semester STRING COMMENT '学期',
        class_code STRING COMMENT '班级编码(课序号)',
        class_name STRING COMMENT '班级名称（可为空）',
        student_num INT COMMENT '班级学生总人数',
        substitute_class_num INT COMMENT '调代课次数',
        workload decimal(5,2) COMMENT '工作量',
        course_code STRING COMMENT '课程编码',
        course_name STRING COMMENT '课程名称'
        ) COMMENT '教师带课表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表--教师带课表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_data(){

    ###############################################################
    #   学年,学期,任课老师工号,每周上课的节数
    ###############################################################

#hive -e "
#
#        create table tmp.tmp_teacher_course as
#            select
#                semester_year ,
#                semester ,
#                code ,
#                class_number course_number,
#                round(nvl((sum(nvl(teaching_hours,0))+sum(nvl(experiment_hours,0))+sum(nvl(computer_hours,0))+sum(nvl(other_hours,0))),0),2) as  WORKLOAD
#            from model.teacher_course_info
#            group by code,semester,semester_year,class_number
#        "

hive -e "
        create table tmp.tmp_teacher_course as
        select
            aa.semester_year ,
            aa.semester ,
            aa.code ,
            aa.course_number,
            nvl(aa.workload,0) workload
        from
            (select
                row_number() over(partition by code,semester,semester_year,class_number order by workload desc) as rownum ,
                a.semester_year ,
                a.semester ,
                a.code ,
                a.class_number course_number,
                a.workload workload
            from (
                    select
                        semester_year ,
                        semester ,
                        code ,
                        class_number,
                        count(1) workload,
                        weekly_times
                    from model.teacher_course_info
                    group by code,semester,semester_year,class_number,weekly_times
            ) a
        ) aa where aa.rownum=1
        "
    ###############################################################
    #   学年,学期,教师编号,调代课次数
    ###############################################################
hive -e "
        create table tmp.tmp_teacher_change_num as
            select
            semester_year,
            semester,
            code,
            course_number,
            COUNT(*) as count
            from model.teacher_change_class_info
            where cousre_type !='sg'
            group by semester_year,semester,code,course_number
        "
    ###############################################################
    #   院系代码,院系名称,专业代码,专业名称,班级代码,班级名称,班级学生人数
    ###############################################################



hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        SELECT DISTINCT
            TRIM(a1.code),
            TRIM(a1.name),
            a1.semester_year,
            a1.semester,
            a1.class_number,
            '',
            nvl(a1.student_number,0) student_number,
            nvl(a5.count,0) count,
            nvl(a4.workload, 0) workload,
            TRIM(a1.course_code),
            TRIM(a1.course_name)
        FROM model.teacher_course_info a1

        LEFT JOIN tmp.tmp_teacher_course a4
            on a1.class_number=a4.course_number
          and  a1.semester_year=a4.semester_year
          and  a1.semester=a4.semester
          and  a1.code =a4.code
        LEFT JOIN tmp.tmp_teacher_change_num a5
            on a1.class_number=a5.course_number
          and  a1.semester_year=a5.semester_year
          and  a1.semester=a5.semester
          and  a1.code =a5.code

       "

    fn_log "导入数据--教师带课表：${HIVE_DB}.${HIVE_TABLE}"

    hive -e "
        drop table tmp.tmp_teacher_course;
        drop table tmp.tmp_teacher_change_num;
     "
}

function export_data() {

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'code,name,semester_year,semester,class_code,class_name,student_num ,substitute_class_num,workload,course_code,course_name'

    fn_log "导出数据--教师带课表：${HIVE_DB}.${HIVE_TABLE}"
}

init_exit
create_table
import_data
export_data
finish

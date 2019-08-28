#!/usr/bin/env bash
#################################################
###  基础表:       课程反馈表
###  维护人:       王浩
###  数据源:       model.basic_teacher_info,model.teacher_course_info,model.student_score_record,model.basic_student_info
###               model.course_change_info,model.course_satisfaction_info,model.course_supervision_info,model.course_evaluation_teaching_info

###  导入方式:      全量导入
###  运行命令:      sh  course_feedback.sh &
###  结果目标:      model.course_feedback
#################################################

cd `dirname $0`
source ../../../config.sh
exec_dir course_feedback

HIVE_DB=app
HIVE_TABLE=course_feedback
TARGET_TABLE=course_feedback

function create_table() {

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

    hive -e "
        CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            semester_year STRING COMMENT '学年',
            semester STRING COMMENT '学期',
            course_code STRING COMMENT '课程代码',
            teacher_code STRING COMMENT '授课教师代码',
            teacher_name STRING COMMENT '授课教师姓名',
            change_num INT COMMENT '调课次数',
            class_num INT COMMENT '课次总数',
            substitute_num INT COMMENT '代课次数',
            class_satisfy_rate INT COMMENT '课堂满意度，如：95表示为95%',
            evaluate_score STRING COMMENT '督导评价分数',
            student_score STRING COMMENT '学生评教分数',
            avg_score STRING COMMENT '总评平均成绩',
            examine_pass_rate INT COMMENT '课程考试及格率，如：95表示为95%',
            examine_good_rate INT COMMENT '课程考试优秀率，如：95表示为95%',
            academy_code STRING COMMENT '学院编号',
            academy_name STRING COMMENT '学院名称',
            major_code STRING COMMENT '专业编号',
            major_name STRING COMMENT '专业名称',
            week_class_hour   STRING     COMMENT '周课时',
            class_attendance   STRING     COMMENT '学生到课率'
        )
        COMMENT '课程反馈表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建--课程反馈表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
    hive -e "
        DROP TABLE IF EXISTS  tmp.tmp_course_score;
    "
     hive -e "
        create table tmp.tmp_course_score  as
       select semester_year,semester,course_code,academy_code,major_code,teacher_code
        ,sum(pass_num)/sum(total_num)*100 as examine_pass_rate,sum(good_num)/sum(total_num)*100 as examine_good_rate
        from (
            select a.major_code,a.major_name,a.academy_code,a.academy_name
            ,b.semester_year as semester_year,b.semester as semester,b.course_code as course_code,b.course_name as course_name,b.code as teacher_code,b.name as teacher_name
            ,case when c.score>60 then 1 else 0 end pass_num
            ,case when c.score>90 then 1 else 0 end good_num
            ,case when c.score>0 then 1 else 0 end total_num
            from model.basic_teacher_info a
            left join model.teacher_course_info b on a.semester_year=b.semester_year and a.code=b.code
            left join
                (select a.code,a.semester_year,a.semester,a.course_name,a.course_code,a.score
                ,b.academy_code,b.academy_name,b.major_code,b.major_name from model.student_score_record a
                left join model.basic_student_info b on a.code=b.code
            )c on b.semester_year=c.semester_year and b.semester=c.semester and b.course_code=c.course_code and a.major_code=c.major_code
        ) aa  group by semester_year,semester,course_code,academy_code,major_code,teacher_code
    "
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
       SELECT
         distinct
         IF(a.semester_year is null,'',a.semester_year) as semester_year
        ,IF(a.semester is null,'',a.semester) as semester
        ,IF(a.course_code is null,'',a.course_code) as course_code
        ,IF(a.teacher_code is null,'',a.teacher_code) as teacher_code
        ,IF(a.teacher_name is null,'',a.teacher_name) as teacher_name
        ,cast(nvl(a.tk,0) as int) as change_num
        ,cast(nvl(h.zks,0) as int) as class_num
        ,cast(nvl(a.dk,0) as int) as substitute_num
        ,0 as class_satisfy_rate
        ,IF(d.score is null,0,cast(d.score as int)) as evaluate_score
        ,0 as student_score
        ,0 as avg_score
        ,cast(nvl(e.examine_pass_rate,0) as int) examine_pass_rate
        ,cast(nvl(e.examine_good_rate,0) as int) examine_good_rate
        ,IF(a.academy_code is null,'',a.academy_code) as academy_code
        ,IF(a.academy_name is null,'',a.academy_name) as academy_name
        ,IF(a.major_code is null,'',a.major_code) as major_code
        ,IF(a.major_name is null,'',a.major_name) as major_name
        ,cast(nvl(f.zks,0) as int) as week_class_hour
        ,nvl(g.bdl,0) as class_attendance
        FROM
            (
            select semester_year,semester,course_code,academy_code,academy_name,major_code,major_name,teacher_name,teacher_code,
								 sum(tk) as tk,sum(dk) as dk from (
								select bt.semester_year,tc.semester,tc.course_code,bt.academy_code,bt.academy_name,bt.major_code,
								bt.major_name,tc.code teacher_code,tc.name as teacher_name,case when  tc.cousre_type='tk'
								then 1 end as tk ,
								case when  tc.cousre_type='dk'
								then 1 end as dk
								from  model.teacher_change_class_info tc left join model.basic_teacher_info bt on
								tc.semester_year=bt.semester_year and tc.code=bt.code
								where tc.cousre_type in('tk','dk')
								) bbb
								group by semester_year,semester,course_code,academy_code,academy_name,major_code,major_name,teacher_name,teacher_code
            )a
        left join model.course_satisfaction_info b on a.semester_year=b.semester_year and a.semester=b.semester and a.course_code=b.course_code
                                                and a.teacher_code=b.teacher_code and a.academy_code=b.academy_code and a.major_code=b.major_code
        left join
            (select semester_year,semester,course_code,academy_code,academy_name,major_code
            ,major_name,teacher_code,teacher_name,count(0) as evaluate_num
            from model.course_supervision_info
            group by semester_year,semester,course_code,academy_code,academy_name,major_code,major_name,teacher_code,teacher_name
            ) c  on a.semester_year=c.semester_year and a.semester=c.semester and a.course_code=c.course_code
                and a.teacher_code=c.teacher_code and a.academy_code=c.academy_code and a.major_code=c.major_code
        left join model.course_evaluation_teaching_info d on a.semester_year=d.semester_year and a.semester=d.semester and a.course_code=d.course_code
                                                        and a.teacher_code=d.teacher_code and a.academy_code=d.academy_code and a.major_code=d.major_code
        left join tmp.tmp_course_score e on a.semester_year=e.semester_year and a.semester=e.semester and a.course_code=e.course_code
                                                        and a.teacher_code=e.teacher_code and a.academy_code=e.academy_code and a.major_code=e.major_code


        left join (
        select semester_year,semester,course_code,teacher_code,academy_code,major_code,
								 avg(ks) as zks from (
								select bt.semester_year,tc.semester,tc.course_code,bt.academy_code,bt.major_code,
								tc.code as teacher_code,
								teaching_hours+experiment_hours+computer_hours+other_hours as ks
								from  model.teacher_course_info tc left join  model.basic_teacher_info bt on
								tc.semester_year=bt.semester_year and tc.code=bt.code

								) bbb
								group by semester_year,semester,course_code,academy_code,major_code,teacher_code
        )  f

        on a.semester_year=f.semester_year and a.semester=f.semester and a.course_code=f.course_code
                and a.teacher_code=f.teacher_code and a.academy_code=f.academy_code and a.major_code=f.major_code

        left join (
        select semester_year,semester,course_code,major_code,teacher_code,academy_code,
								 avg(sign_rate) as bdl from  model.course_implement group by
								 semester_year,semester,course_code,academy_code,major_code,teacher_code
        ) g on

         a.semester_year=g.semester_year and a.semester=g.semester and a.course_code=g.course_code
                and a.teacher_code=g.teacher_code and a.academy_code=g.academy_code and a.major_code=g.major_code

        left join
        (select  code,ROUND((total_hour/50),0)
								  as zks from  model.basic_course_info )  h on h.code =a.course_code
    "



    fn_log "导入数据--课程反馈表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'semester_year,semester ,course_code ,teacher_code ,teacher_name ,change_num ,class_num ,substitute_num ,
         class_satisfy_rate  ,evaluate_score ,student_score,avg_score ,examine_pass_rate ,examine_good_rate ,academy_code ,academy_name,major_code ,major_name,week_class_hour,class_attendance '

    fn_log "导出数据--课程反馈表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish
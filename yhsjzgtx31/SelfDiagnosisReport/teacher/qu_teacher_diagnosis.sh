#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_teacher_diagnosis

HIVE_DB=assurance
TARGET_TABLE=qu_teacher_diagnosis
function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：学年学期教师编号(关联表qu_teacher_diagnosis_report_record)',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                semester String comment '学期 1 第一学期 2 第二学期',
                teacher_no String comment '教师编号',
                teacher_name String comment '教师姓名',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '教师诊断报告信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——教师诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTER}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,semester,teacher_no,teacher_name,item_key,item_value,create_time'
    fn_log "导出数据--教师诊断报告信息表:${HIVE_DB}.${TARGET_TABLE}"
}

#教师籍贯
function teacher_native_place() {
#exec_dir teacher_native_place
HIVE_TABLE=teacher_native_place
 ITEM_KEY=JG
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.native_place  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_teacher_info a
                where a.semester_year = '${SEMESTER_YEARS}' and a.native_place != ''
            "
    fn_log "导入数据 —— 教师诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师民族
function teacher_ethnic() {
#exec_dir teacher_ethnic
HIVE_TABLE=teacher_ethnic
 ITEM_KEY=MZ
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.ethnic  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_teacher_info a
                    where a.semester_year = '${SEMESTER_YEARS}' and a.ethnic != ''
            "
    fn_log "导入数据 —— 教师诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师学历
function teacher_education() {
#exec_dir teacher_education
HIVE_TABLE=teacher_education
 ITEM_KEY=XL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                  '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.education  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.basic_teacher_info a where a.semester_year = '${SEMESTER_YEARS}' and a.education != ''
            "
    fn_log "导入数据 —— 教师学历：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师所属部门名称
function teacher_subordinate_departments() {
#exec_dir subordinate_departments
HIVE_TABLE=subordinate_departments
 ITEM_KEY=SSBMMC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.second_dept_name  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.basic_teacher_info a where a.semester_year = '${SEMESTER_YEARS}' and a.second_dept_name != ''
            "
    fn_log "导入数据 —— 教师所属部门名称：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师职称
function teacher_professional_title() {
#exec_dir professional_title
HIVE_TABLE=professional_title
 ITEM_KEY=ZC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.professional_title  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where a.semester_year = '${SEMESTER_YEARS}' and a.professional_title != ''
            "
    fn_log "导入数据 —— 教师职称：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师代课数量
function teacher_Number_of_substitute_classes() {
#exec_dir Number_of_substitute_classes
HIVE_TABLE=Number_of_substitute_classes
 ITEM_KEY=DKSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                nvl(b.c,0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.teacher_change_class_info a
                left join
                (
                    select
                     count(course_code) as c,
                     code,
                     name
                     from model.teacher_change_class_info
                     where cousre_type = 'dk'
                     and semester_year = '${SEMESTER_YEARS}'
                     and semester = '${SEMESTER}'
                     group by code,name
                 ) b
                 on a.code=b.code
                 and semester_year = '${SEMESTER_YEARS}'
                 and semester = '${SEMESTER}'
            "
    fn_log "导入数据 —— 教师代课数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师课时学时
function teacher_Class_hour() {
#exec_dir Class_hour
HIVE_TABLE=Class_hour
 ITEM_KEY=KSXS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_no)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_no as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 nvl(a.c,0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                        select
                        cast(sum(a.teaching_hours)+sum(a.experiment_hours)+
                        sum(a.computer_hours)+sum(a.other_hours) as decimal(9,1)) as c,
                        a.code as teacher_no,
                        a.name as teacher_name
                        from model.teacher_course_info a
                        where  a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTER}'
                        group by a.code,a.name
                    ) a
            "
    fn_log "导入数据 —— 教师课时学时：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师代课班级数量
function teacher_Substitute_class() {
#exec_dir Substitute_class
HIVE_TABLE=Substitute_class
ITEM_KEY=DKBJSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_no)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_no as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 (
                    select
                        count(distinct a.class_number) as c,
                        a.code as teacher_no,
                        a.name as teacher_name
                        from model.teacher_course_info a
                        where  a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTER}'
                        group by a.code,a.name
                 ) a
            "
    fn_log "导入数据 —— 教师代课班级数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师代课学生总数
function teacher_Substitute_student() {
#exec_dir Substitute_student
HIVE_TABLE=Substitute_student
 ITEM_KEY=DKXSZS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_no)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_no as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  (
                    select
                        sum(a.student_num) as c,
                        a.code as teacher_no,
                        a.name as teacher_name
                        from app.teacher_lessons_info a
                        where  a.semester_year = '${SEMESTER_YEARS}'
                        and a.semester = '${SEMESTER}'
                        group by a.code,a.name
                 )  a
            "
    fn_log "导入数据 —— 教师代课学生总数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师所带学生平均成绩
function teacher_Average_student_achievement() {
#exec_dir Average_student_achievement
HIVE_TABLE=Average_student_achievement
 ITEM_KEY=XSPJCJ
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_no)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_no as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 nvl(a.c,0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  (
                      select
                            a.code as teacher_no,
                            a.name as teacher_name,
                            cast(avg(c.score) as decimal(9,2))  as c
                            from
                            app.teacher_lessons_info a
                            left join
                            app.basic_semester_student_info b on a.class_code=b.class_code
                            left join
                            model.student_score_record c on b.code=c.code
                            where a.semester_year = '${SEMESTER_YEARS}'
                            and a.semester = '${SEMESTER}'
                            group by a.code,
                            a.name
                        ) a


            "
    fn_log "导入数据 —— 教师所带学生平均成绩：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师所带学生考试通过率
function teacher_Examination_pass_rate() {
#exec_dir Examination_pass_rate
HIVE_TABLE=Examination_pass_rate
 ITEM_KEY=KSTGL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_no)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_no as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  (
                            select
                            a.code as teacher_no,
                            a.name as teacher_name,
                            nvl(cast((count(case when c.score >60 then b.code  end)/count(b.code))*100 as
                             decimal(9,2)),0) as c
                            from
                            app.teacher_lessons_info a
                            left join
                            app.basic_semester_student_info b on a.class_code=b.class_code
                            left join
                            model.student_score_record c on b.code=c.code
                            where a.semester_year = '${SEMESTER_YEARS}'
                            and a.semester = '${SEMESTER}'
                            group by a.code,
                            a.name
                        ) a
            "
    fn_log "导入数据 —— 教师所带学生考试通过率：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师发表论文数量
function teacher_Publishing_papers() {
#exec_dir Publishing_papers
HIVE_TABLE=Publishing_papers
ITEM_KEY=FBLWSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_code as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.scientific_paper_personnel_info a
                  where a.semester_year = '${SEMESTER_YEARS}'
                  and a.teacher_name !=''
                  group by a.teacher_code,a.teacher_name

            "
    fn_log "导入数据 —— 教师发表论文数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师参编著作数量
function teacher_Participating_works() {
#exec_dir Participating_works
HIVE_TABLE=Participating_works
 ITEM_KEY=CBZZSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_code)  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_code as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.scientific_work_personnel_info a
                where a.author_type='2'
                and a.semester_year = '${SEMESTER_YEARS}'
                group by a.teacher_code,a.teacher_name
            "
    fn_log "导入数据 —— 教师诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师专利数量
function teacher_Number_of_patents() {
#exec_dir Number_of_patents
HIVE_TABLE=Number_of_patents
 ITEM_KEY=ZLSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.author_code)  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.author_code as teacher_no,
                a.author as teacher_name,
                '${ITEM_KEY}' as item_key,
                 count(a.patent_code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.scientific_author_patent_info a
                where  a.semeste_year =  '${SEMESTER_YEARS}'
                group  by a.author_code,a.author
            "
    fn_log "导入数据 —— 教师专利数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师社会服务
function teacher_Social_services() {
#exec_dir Social_services
HIVE_TABLE=Social_services
 ITEM_KEY=SHFWSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.teacher_code)  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.teacher_code as teacher_no,
                a.teacher_name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 count(a.project_name)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.teacher_social_work a
                    where a.semester_year =  '${SEMESTER_YEARS}'
                    group by a.teacher_code, a.teacher_name
            "
    fn_log "导入数据 —— 教师社会服务：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师培训次数
function teacher_Training_times() {
#exec_dir Training_times
HIVE_TABLE=Training_times
 ITEM_KEY=PXCS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.teacher_growing_info a
                    where a.growing_type = '1' and
                    a.semester_year =  '${SEMESTER_YEARS}'
                    group by a.code, a.name
            "
    fn_log "导入数据 —— 教师诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#教师学历提升
function teacher_Educational_background_promotion() {
#exec_dir Educational_background_promotion
HIVE_TABLE=Educational_background_promotion
ITEM_KEY=XLTS
LASTYEAR=$((${SEMESTER_YEARS:0:4}-1))
LASTSEMESTER_YEARS=${LASTYEAR}"-"$((${LASTYEAR} + 1))
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTER}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTER}' as semester,
                a.code as teacher_no,
                a.name as teacher_name,
                '${ITEM_KEY}' as item_key,
                case when a.education=b.education then '无' else '有' end  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  (
                      select
                      code,
                      name,
                      education
                      from
                      model.basic_teacher_info
                      where semester_year = '${SEMESTER_YEARS}'
                  ) a
                  left join
                  (
                      select
                      code,
                      name,
                      education
                      from model.basic_teacher_info
                      where semester_year = '${LASTSEMESTER_YEARS}'
                  )b
                  on a.code=b.code
            "
    fn_log "导入数据 —— 教师诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}


function select_semester_year(){
    SEMESTER_YEARS=`find_mysql_data "
    select semester_year from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
     "`
    SEMESTER=`find_mysql_data "
    select semester from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
    "`

    if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEAR IS NULL!"
    else
         echo "SEMESTER_YEAR IS NOT NULL"
           #开始依次执行
        #籍贯
        teacher_native_place >> ${RUNLOG} 2>&1
        #民族
        teacher_ethnic >> ${RUNLOG} 2>&1
        #学历
        teacher_education >> ${RUNLOG} 2>&1
        #教师所属部门名称
        teacher_subordinate_departments >> ${RUNLOG} 2>&1
        #教师职称
        teacher_professional_title >> ${RUNLOG} 2>&1
        #教师代课数量
        teacher_Number_of_substitute_classes >> ${RUNLOG} 2>&1
         #教师课时学时
         teacher_Class_hour >> ${RUNLOG} 2>&1
        #教师代课班级数量
         teacher_Substitute_class >> ${RUNLOG} 2>&1
        #教师代课学生总数
        teacher_Substitute_student >> ${RUNLOG} 2>&1
        #教师学生平均成绩
        teacher_Average_student_achievement >> ${RUNLOG} 2>&1
        #教师学生考试通过率
        teacher_Examination_pass_rate >> ${RUNLOG} 2>&1
        #教师发表论文数量
        teacher_Publishing_papers >> ${RUNLOG} 2>&1
        #教师参编著作数量
        teacher_Participating_works >> ${RUNLOG} 2>&1
        #教师专利数量
        teacher_Number_of_patents >> ${RUNLOG} 2>&1
        #社会服务
        teacher_Social_services >> ${RUNLOG} 2>&1
        #教师培训次数
        teacher_Training_times >> ${RUNLOG} 2>&1
        #教师学历提升
        teacher_Educational_background_promotion >> ${RUNLOG} 2>&1
    fi

}
function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
    years=2
    for((i=1;i<=2;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      SEMESTER_YEARS=${PRE_YEAR}"-"${NOW_YEAR}
      for((j=1;j<=2;j++));
      do
      SEMESTER=${j}
      echo $SEMESTER_YEARS"=="$SEMESTER
        #教师代课数量
        teacher_Number_of_substitute_classes >> ${RUNLOG} 2>&1
         #教师课时学时
         teacher_Class_hour >> ${RUNLOG} 2>&1
        #教师代课班级数量
         teacher_Substitute_class >> ${RUNLOG} 2>&1
        #教师学生平均成绩
        teacher_Average_student_achievement >> ${RUNLOG} 2>&1
        #教师学生考试通过率
        teacher_Examination_pass_rate >> ${RUNLOG} 2>&1

      done
    done
}

RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
#最新数据
select_semester_year >> ${RUNLOG} 2>&1
#近两年数据执行
#getYearData>> ${RUNLOG} 2>&1
finish




#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_college_quality_report
HIVE_DB=assurance
TARGET_TABLE=qu_college_quality_report

# exec_dir方法：如果在单独执行下面方法时，可以根据需要将方法中的exec_dir方法放开进行查看日志，
# 如果统一执行全部方法时将日志在  ./logs/$0_`date +%Y-%m-%d`.log 2>&1 下
# getYearData方法 执行近两年的1，2学期的数据
# select_semester_year方法执行最新学年学期数据
# plan_getYearData方法执行规划等数据

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '学院层面质量报告'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——学院层面质量报告：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,item_key,item_value,create_time'
    fn_log "导出数据--学院层面质量报告:${HIVE_DB}.${TARGET_TABLE}"
}



#在校生总人数
function Total_number_of_students_in_school() {
#exec_dir Total_number_of_students_in_school
HIVE_TABLE=Total_number_of_students_in_school
 ITEM_KEY=ZXSZRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                       select
                       count(a.code) as c
                       from
                       app.basic_semester_student_info a left join
                       model.basic_student_info b
                       where
                       a.code=b.code
                       and a.class_code=b.class_code
                       and a.major_code=b.major_code
                       and a.academy_code=b.academy_code
                       and b.status = '1' and  b.in_school = '1'
                       and a.semester_year='${SEMESTER_YEARS}'
                       and a.semester='${SEMESTERS}'
                   ) a
            "
    fn_log "导入数据 —— 在校生总人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教职工人数
function Number_of_staff() {
#exec_dir Number_of_staff
HIVE_TABLE=Number_of_staff
 ITEM_KEY=JZGRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                       select
                       count(code) as c
                       from
                       model.basic_teacher_info where is_quit = '2'
                       and semester_year = '${SEMESTER_YEARS}'
                   ) a
            "
    fn_log "导入数据 —— 教职工人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#生师比
function Student_to_Teacher_Ratio() {
#exec_dir Student_to_Teacher_Ratio
HIVE_TABLE=Student_to_Teacher_Ratio
ITEM_KEY=SSB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}'as item_key,
                 CONCAT(a.c,':', b.c) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  (
                       select
                       count(a.code) as c
                       from
                       app.basic_semester_student_info a left join
                       model.basic_student_info b
                       where
                       a.code=b.code
                       and a.class_code=b.class_code
                       and a.major_code=b.major_code
                       and a.academy_code=b.academy_code
                       and b.status = '1' and  b.in_school = '1'
                       and a.semester_year='${SEMESTER_YEARS}'
                       and a.semester='${SEMESTERS}'
                   ) a ,
                   (
                       select
                       count(code) as c
                       from
                       model.basic_teacher_info where is_quit = '2'
                       and semester_year = '${SEMESTER_YEARS}'
                   ) b

            "
    fn_log "导入数据 —— 生师比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#辅导员人数
function Number_of_Counselors() {
#exec_dir Number_of_Counselors
HIVE_TABLE=Number_of_Counselors
 ITEM_KEY=FDYRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                       select
                       count(code) as c
                       from
                       app.teacher_managerial_position_record
                       where
                       is_instructor = '1'
                       and semester_year =  '${SEMESTER_YEARS}'
                    ) a
            "
    fn_log "导入数据 —— 辅导员人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#辅导员生师比
function Counselor_student_teacher_ratio() {
#exec_dir Counselor_student_teacher_ratio
HIVE_TABLE=Counselor_student_teacher_ratio
 ITEM_KEY=FDYSSB
create_table
    hive -e "
    INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
          select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}'as item_key,
                 CONCAT(a.c,':', b.c)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  (
                       select
                       count(a.code) as c
                       from
                       app.basic_semester_student_info a left join
                       model.basic_student_info b
                       where
                       a.code=b.code
                       and a.class_code=b.class_code
                       and a.major_code=b.major_code
                       and a.academy_code=b.academy_code
                       and b.status = '1' and  b.in_school = '1'
                       and a.semester_year='${SEMESTER_YEARS}'
                       and a.semester='${SEMESTERS}'
                   ) a,
                   (
                      select
                       count(code) as c
                       from
                       app.teacher_managerial_position_record
                       where
                       is_instructor = '1'
                       and semester_year =  '${SEMESTER_YEARS}'
                   ) b

            "
    fn_log "导入数据 —— 辅导员生师比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#专任教师数量
function Number_of_full_time_teachers() {
#exec_dir Number_of_full_time_teachers
HIVE_TABLE=Number_of_full_time_teachers
 ITEM_KEY=ZRJSSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a
                  where a.teacher_type = '校内专任教师'
                  and a.is_quit='2'
                  and semester_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 专任教师数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#专任教师正高级职称人数
function Full_time_teachers_are_high() {
#exec_dir Full_time_teachers_are_high
HIVE_TABLE=Full_time_teachers_are_high
 ITEM_KEY=ZRJSZGJZCRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a
                  where a.teacher_type = '校内专任教师'
                  and a.professional_title_level = '正高'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 专任教师正高级职称人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#专任教师副高职称人数
function Deputy_Senior_Teacher() {
#exec_dir Deputy_Senior_Teacher
HIVE_TABLE=Deputy_Senior_Teacher
ITEM_KEY=ZRJSFGJZCRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   model.basic_teacher_info a
                   where a.teacher_type = '校内专任教师'
                   and a.professional_title_level = '副高'
                   and a.is_quit='2'
                   and a.semester_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 专任教师副高职称人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#专任教师副高以上职称占比
function The_proportion_of_full_time_teachers_above_deputy_senior() {
#exec_dir The_proportion_of_full_time_teachers_above_deputy_senior
HIVE_TABLE=The_proportion_of_full_time_teachers_above_deputy_senior
 ITEM_KEY=ZRJSFGJYSZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
               CONCAT(cast((a.c/b.c)*100 as decimal(9,2)),'','%') as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               (
                  select
                  count(0) as c
                  from
                  model.basic_teacher_info a
                   where a.teacher_type = '校内专任教师'
                   and a.professional_title_level = '副高'
                   and a.is_quit='2'
                   and a.semester_year = '${SEMESTER_YEARS}'
                )a,
               (
                  select
                  count(0) as c
                  from
                  model.basic_teacher_info a
                  where a.teacher_type = '校内专任教师'
                  and a.is_quit='2'
                  and semester_year = '${SEMESTER_YEARS}'
                 )b

            "
    fn_log "导入数据 —— 专任教师副高以上职称占比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#专任教师具有研究生以上学历的教师人数
function Teachers_with_postgraduate_education_or_above() {
#exec_dir Teachers_with_postgraduate_education_or_above
HIVE_TABLE=Teachers_with_postgraduate_education_or_above
 ITEM_KEY=ZRJSYJSXLYSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                  a.c as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 (
                     select
                     count(a.code) as c,
                     a.semester_year
                     from  model.basic_teacher_info a
                     where a.teacher_type = '校内专任教师'
                     and a.is_quit='2' and a.education in('博士研究生','硕士研究生')
                     and a.semester_year = '${SEMESTER_YEARS}'
                     group by a.semester_year
                 ) a
            "
    fn_log "导入数据 —— 专任教师具有研究生以上学历的教师人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#专任教师具有研究生以上学历的教师人数占比
function The_proportion_of_teachers_with_postgraduate_education_or_above() {
#exec_dir The_proportion_of_teachers_with_postgraduate_education_or_above
HIVE_TABLE=The_proportion_of_teachers_with_postgraduate_education_or_above
 ITEM_KEY=ZRJSYJSXLYSRSZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
               CONCAT(cast((a.c/b.c)*100 as decimal(9,2)),'','%') as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                     select
                     count(a.code) as c,
                     a.semester_year
                     from  model.basic_teacher_info a
                     where a.teacher_type = '校内专任教师'
                     and a.is_quit='2' and a.education in('博士研究生','硕士研究生')
                     and a.semester_year = '${SEMESTER_YEARS}'
                     group by a.semester_year
                ) a,
                (
                  select
                  count(0) as c
                  from
                  model.basic_teacher_info a
                  where a.teacher_type = '校内专任教师'
                  and a.is_quit='2'
                  and semester_year = '${SEMESTER_YEARS}'
                 )b
            "
    fn_log "导入数据 —— 专任教师具有研究生以上学历的教师人数占比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#双师素质教师
function Double_qualified_teachers() {
#exec_dir Double_qualified_teachers
HIVE_TABLE=Double_qualified_teachers
 ITEM_KEY=SSSZJS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_teacher_info a
                    where a.is_double_professionally = '1'
                    and a.is_quit='2'
                    and a.semester_year = '${SEMESTER_YEARS}'

            "
    fn_log "导入数据 —— 双师素质教师：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#双师素质教师占比
function The_proportion_of_teachers_with_double_qualifications() {
#exec_dir The_proportion_of_teachers_with_double_qualifications
HIVE_TABLE=The_proportion_of_teachers_with_double_qualifications
 ITEM_KEY=SSSZJSZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
               CONCAT(cast((a.c/b.c)*100 as decimal(9,2)),'','%') as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                    select
                    count(0) as c
                    from
                    model.basic_teacher_info a
                    where a.is_double_professionally = '1'
                    and a.is_quit='2'
                    and a.semester_year = '${SEMESTER_YEARS}'
                ) a,
                 (
                  select
                  count(0) as c
                  from
                  model.basic_teacher_info a
                  where a.teacher_type = '校内专任教师'
                  and a.is_quit='2'
                  and semester_year = '${SEMESTER_YEARS}'
                 )b
            "
    fn_log "导入数据 —— 双师素质教师占比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#招生专业数量
function Number_of_enrollment_Majors() {
#exec_dir Number_of_enrollment_Majors
HIVE_TABLE=Number_of_enrollment_Majors
 ITEM_KEY=ZSZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                 select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                enroll_student_major_count as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                from
                app.major_total_info
                where semester_year = '${SEMESTER_YEARS}' and TYPE='1'
            "
    fn_log "导入数据 —— 招生专业数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#三年制专业数量
function Quantity_of_three_year_Majors() {
#exec_dir Quantity_of_three_year_Majors
HIVE_TABLE=Quantity_of_three_year_Majors
ITEM_KEY=SNZZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.c as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                        select
                        count(code) as c
                        from model.basic_major_info
                        where educational_system = '3年制'
                        and semester_year = '${SEMESTER_YEARS}'
                    ) a
            "
    fn_log "导入数据 —— 三年制专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#专业大类名称
function Major_categories() {
#exec_dir Major_categories
HIVE_TABLE=Major_categories
 ITEM_KEY=SYZYDLMC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                concat_ws('、',collect_set(a.discipline_type)) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                         select
                         case
                         when discipline_type='LGNY' then '理工农医类'
                         when discipline_type='RWSK' then '人文社科类'
                         when discipline_type='QT' then '其他类'
                         end as discipline_type
                         from model.basic_major_info
                         where semester_year = '${SEMESTER_YEARS}'
                         and type='1' and educational_system='3年制'
                         group by discipline_type
                         limit 2
                    ) a
            "
    fn_log "导入数据 —— 专业大类名称：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}


#大类数量
function Large_class_quantity() {
#exec_dir Large_class_quantity
HIVE_TABLE=Large_class_quantity
ITEM_KEY=DLSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(DISTINCT discipline_type) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                     model.basic_major_info
                     where semester_year='${SEMESTER_YEARS}'
                     and type='1' and educational_system='3年制'

            "
    fn_log "导入数据 —— 大类数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#二级学院名称 用、分开
function Name_of_Secondary_Colleges_and_Departments() {
#exec_dir Name_of_Secondary_Colleges_and_Departments
HIVE_TABLE=Name_of_Secondary_Colleges_and_Departments
 ITEM_KEY=EJXYMC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                concat_ws('、',collect_set(a.academy_name)) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                        select
                         distinct
                         academy_name
                         from app.basic_semester_student_info
                         where semester_year = '${SEMESTER_YEARS}'
                    ) a
            "
    fn_log "导入数据 —— 二级学院名称 用、分开：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}


#二级学院数量
function Coefficient_Quantity_of_Secondary_College() {
#exec_dir Coefficient_Quantity_of_Secondary_College
HIVE_TABLE=Coefficient_Quantity_of_Secondary_College
 ITEM_KEY=EJXYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.num as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                        select
                        count( distinct academy_name) as num
                        from
                        app.basic_semester_student_info
                        where semester_year = '${SEMESTER_YEARS}'

                    ) a
            "
    fn_log "导入数据 —— 二级学院数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#开设课程数量
function Number_of_courses_offered() {
#exec_dir Number_of_courses_offered
HIVE_TABLE=Number_of_courses_offered
ITEM_KEY=KSKCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.number as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                      select
                      count(distinct a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                    ) a
            "
    fn_log "导入数据 —— 开设课程数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#理论类课程数量
function Number_of_theoretical_courses() {
#exec_dir Number_of_theoretical_courses
HIVE_TABLE=Number_of_theoretical_courses
 ITEM_KEY=LLLKCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.number as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                      and a.category='0'
                    ) a
            "
    fn_log "导入数据 —— 理论类课程数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#理论课占比
function Proportion_of_theoretical_courses() {
#exec_dir Proportion_of_theoretical_courses
HIVE_TABLE=Proportion_of_theoretical_courses
ITEM_KEY=LLLCCSLKSKCSLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                CONCAT(cast(a.number/b.number *100 as decimal(9,2)),'','%') as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='2'
                      and a.category='0'
                    ) a,
                     (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                    ) b
            "
    fn_log "导入数据 —— 理论课占比：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#理论+实践类课程数量
function Theory_and_Practice_Course() {
exec_dir Theory_and_Practice_Course
HIVE_TABLE=Theory_and_Practice_Course
 ITEM_KEY=LLJSJLCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.number as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                      and a.category='1'
                    ) a
            "
    fn_log "导入数据 —— 理论+实践类课程数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#理论+实践类课程占比
function Proportion_of_theoretical_and_practical_courses() {
#exec_dir Proportion_of_theoretical_and_practical_courses
HIVE_TABLE=Proportion_of_theoretical_and_practical_courses
 ITEM_KEY=LLJSJLCSLKCSLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                CONCAT(cast(a.number/b.number *100 as decimal(9,2)),'','%') as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                      and a.category='2'
                    ) a,
                    (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                    ) b

            "
    fn_log "导入数据 —— 理论+实践类课程占比：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#实践类课程数量
function Number_of_Practice_Courses() {
#exec_dir Number_of_Practice_Courses
HIVE_TABLE=Number_of_Practice_Courses
ITEM_KEY=SJKCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.number as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}' and a.is_open='1'
                      and a.category='1'
                    ) a
            "
    fn_log "导入数据 —— 实践类课程数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#实践类课程占比
function Proportion_of_Practice_Courses() {
#exec_dir Proportion_of_Practice_Courses
HIVE_TABLE=Proportion_of_Practice_Courses
ITEM_KEY=SJKCSLKCSLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                CONCAT(cast(a.number/b.number *100 as decimal(9,2)),'','%') as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                      and a.category='1'
                    ) a,
                    (
                      select
                      count(course_code) as number
                      from  model.major_course_record
                      where semester_year = '${SEMESTER_YEARS}'
                      and semester='${SEMESTERS}'and a.is_open='1'
                    ) b
            "
    fn_log "导入数据 —— 实践类课程占比：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#校企合作开发课程数
function School_Enterprise_Cooperative_Development_Course() {
#exec_dir School_Enterprise_Cooperative_Development_Course
HIVE_TABLE=School_Enterprise_Cooperative_Development_Course
ITEM_KEY=XQHZKFKCS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.number as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                      select
                      count(a.course_code) as number
                      from  model.major_course_record a
                      where a.semester_year = '${SEMESTER_YEARS}'
                      and a.semester='${SEMESTERS}'and a.is_open='1'
                      and a.is_corporate_development='1'
                 ) a
            "
    fn_log "导入数据 —— 校企合作开发课程数：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#生师比状况
function Student_teacher_ratio() {
#exec_dir Student_teacher_ratio
HIVE_TABLE=Student_teacher_ratio
ITEM_KEY=SSBZK
create_table

    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}'as item_key,
                case when cast((a.stunum / b.teanum)*100 as decimal(9,2)) > 200
                then '生师比略低于国家标准，需招聘引进一些教职工'
                else '生师比情况良好' end as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               (
                       select
                       count(a.code) as stunum
                       from
                       app.basic_semester_student_info a left join
                       model.basic_student_info b
                       where
                       a.code=b.code
                       and a.class_code=b.class_code
                       and a.major_code=b.major_code
                       and a.academy_code=b.academy_code
                       and b.status = '1' and  b.in_school = '1'
                       and a.semester_year='${SEMESTER_YEARS}'
                       and a.semester='${SEMESTERS}'
                   ) a ,
                   (
                       select
                       count(code) as teanum
                       from
                       model.basic_teacher_info where is_quit = '2'
                       and semester_year = '${SEMESTER_YEARS}'
                   ) b
            "
    fn_log "导入数据 —— 生师比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#辅导员生师比状况
function The_Situation_of_Student_Teacher_Ratio_of_Counselors() {
#exec_dir The_Situation_of_Student_Teacher_Ratio_of_Counselors
HIVE_TABLE=The_Situation_of_Student_Teacher_Ratio_of_Counselors
ITEM_KEY=FDYSSBZK
create_table
    hive -e "
          select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}'as item_key,
                 case when cast((a.stunum / b.teanum) *100 as decimal(9,2)) > 200
                 then '辅导员生师比略低于国家标准，需招聘引进一些辅导员。'
                 else '辅导员生师比情况良好' end
                  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                       select
                       count(a.code) as stunum
                       from
                       app.basic_semester_student_info a left join
                       model.basic_student_info b
                       where
                       a.code=b.code
                       and a.class_code=b.class_code
                       and a.major_code=b.major_code
                       and a.academy_code=b.academy_code
                       and b.status = '1' and  b.in_school = '1'
                       and a.semester_year='${SEMESTER_YEARS}'
                       and a.semester='${SEMESTERS}'
                   ) a,
                   (
                      select
                       count(code) as teanum
                       from
                       app.teacher_managerial_position_record
                       where
                       is_instructor = '1'
                       and semester_year =  '${SEMESTER_YEARS}'
                   ) b
            "

    fn_log "导入数据 —— 辅导员生师比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}


#规划总数
function Total_planning() {
#exec_dir Total_planning
ITEM_KEY=GHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a
                where a.plan_layer = 'G_COLLEGE' and a.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#已完成规划数量
function Planned_Quantity_Completed() {
exec_dir Planned_Quantity_Completed
ITEM_KEY=YWCGHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a
                where a.plan_layer = 'G_COLLEGE' and a.status='NORMAL' and a.plan_status = 'YWC'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 已完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#未完成规划数量
function Uncompleted_Planning_Quantity() {
#exec_dir Uncompleted_Planning_Quantity
ITEM_KEY=WWCGHSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a
                where a.plan_layer = 'G_COLLEGE' and a.status='NORMAL' and a.plan_status!='YWC'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 未完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#已完成任务数量
function Number_of_completed_tasks() {
#exec_dir Number_of_completed_tasks
ITEM_KEY=YWCRWSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(b.task_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            left join
            tm_task_info b
            on a.plan_no = b.plan_no
            where a.plan_layer = 'COLLEGE' and
            b.task_status = 'YWC' and
            b.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 已完成任务数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#规划任务总数
function Total_number_of_planning_tasks() {
#exec_dir Total_number_of_planning_tasks
ITEM_KEY=GHHRWZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.task_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                tm_task_info a
                left join
                pm_college_plan_info b
                on a.plan_no=b.plan_no
                where  a.task_type = 'GHRW' and
                b.plan_layer = 'COLLEGE' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#除了学院层面外其他层面规划总数
function Total_number_of_plans_except_for_Colleges() {
#exec_dir Total_number_of_plans_except_for_Colleges
ITEM_KEY=CLXYCMWQTCMGHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
               concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a
                where a.plan_layer != 'COLLEGE' and
                a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 除了学院层面外其他层面规划总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#除了学院层面外其他层面规划已完成
function Planning_at_all_levels_except_the_College_has_been_completed() {
#exec_dir Planning_at_all_levels_except_the_College_has_been_completed
ITEM_KEY=CLXYCMWQTCMGHZSYEC
find_mysql_data " delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' "
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a
                where a.plan_layer != 'COLLEGE'
                and a.plan_layer='YWC' and
                a.start_date between '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 除了学院层面外其他层面规划已完成 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#除了学院层面外其他层面规划未完成
function Planning_at_all_levels_except_the_College_is_not_completed() {
#exec_dir Planning_at_all_levels_except_the_College_is_not_completed
ITEM_KEY=CLXYCMWQTCMGHZSWWC
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a where plan_layer!= 'COLLEGE'
                and a.plan_layer!='YWC' and
                a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 除了学院层面外其他层面规划未完成 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#五个层面质控点数量
function Number_of_Quality_Control_Points_at_Five_Levels() {
#exec_dir Number_of_Quality_Control_Points_at_Five_Levels
ITEM_KEY=WGCMZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 (a.number+b.number+c.number+e.number+e.number) as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              (select count(quality_no) as number from im_teacher_target_standard_record where semester_year = '${SEMESTER_YEARS}') a,
              (select count(quality_no) as number from im_student_target_standard_record where semester_year = '${SEMESTER_YEARS}') b,
              (select count(quality_no) as number from im_major_target_standard_record where semester_year = '${SEMESTER_YEARS}') c,
              (select count(quality_no) as number from im_course_target_standard_record where semester_year = '${SEMESTER_YEARS}') d,
              (select count(quality_no) as number from im_college_target_standard_record where  semester_year = '${SEMESTER_YEARS}') e

            "
    fn_log "导入数据 —— 五个层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#学院层面质控点
function Quality_Control_Points_at_College_Level() {
#exec_dir Quality_Control_Points_at_College_Level
ITEM_KEY=XYZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.quality_no)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                im_quality_info a
                where a.index_layer = 'COLLEGE'
                and substr(a.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 学院层面质控点 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#五个层面达标质控点
function Quality_Control_Points_for_Achieving_Standards_at_Five_Levels() {
#exec_dir Quality_Control_Points_for_Achieving_Standards_at_Five_Levels
ITEM_KEY=DBZKD
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                a.number+b.number+c.number+e.number+e.number as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              (select count(quality_no) as number from im_teacher_target_standard_record where is_standard = 'YES' and semester_year = '${SEMESTER_YEARS}') a,
              (select count(quality_no) as number from im_student_target_standard_record where is_standard = 'YES' and semester_year = '${SEMESTER_YEARS}') b,
              (select count(quality_no) as number from im_major_target_standard_record where is_standard = 'YES' and semester_year = '${SEMESTER_YEARS}') c,
              (select count(quality_no) as number from im_course_target_standard_record where is_standard = 'YES' and semester_year = '${SEMESTER_YEARS}') d,
              (select count(quality_no) as number from im_college_target_standard_record where is_standard = 'YES' and semester_year = '${SEMESTER_YEARS}') e

            "
    fn_log "导入数据 —— 五个层面达标质控点 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#除了学院层面外其他层面质控点总数
function Total_number_of_levels_other_than_college() {
#exec_dir Total_number_of_levels_other_than_college
ITEM_KEY=CLXYCMWQTCMZKDZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.number as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
             (select count(quality_no) as number from im_quality_info where index_layer !='COLLEGE'
              and substr(create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
             ) a
            "
    fn_log "导入数据 —— 除了学院层面外其他层面质控点总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#所有任务总数
function Total_task() {
#exec_dir Total_task
ITEM_KEY=RWZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.number as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
             (
                 select count(a.task_no) as number from tm_task_info a
                 where a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
             ) a
            "
    fn_log "导入数据 —— 所有任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#所有任务完成数量
function Number_of_tasks_completed() {
#exec_dir Number_of_tasks_completed
ITEM_KEY=RWWCQK
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.number as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
             (
             select count(task_no) as number from tm_task_info
             where task_status = 'YWC' and  start_date between '${BEGIN_TIME}' and '${END_TIME}'
             ) a
            "
    fn_log "导入数据 —— 所有任务完成数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

#任务完成率
function Task_completion_rate() {
#exec_dir Task_completion_rate
ITEM_KEY=RWWCL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT(cast((a.number/b.number)*100 as decimal(9,2)),'','%') as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (
             select count(task_no) as number from tm_task_info
             where task_status = 'YWC' and  start_date between '${BEGIN_TIME}' and '${END_TIME}'
             ) a,
             (
             select count(task_no) as number from tm_task_info
             where start_date between '${BEGIN_TIME}' and '${END_TIME}'
             ) b
            "
    fn_log "导入数据 —— 学院层面质控点 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}


function select_semester_year() {

    SEMESTER_YEARS=`find_mysql_data "
    select semester_year from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
     "`
    SEMESTERS=`find_mysql_data "
    select semester from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
    "`

   if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEAR IS NULL!"
    else
         echo "SEMESTER_YEAR IS NOT NULL"
         #开始依次执行
         #在校生总人数
#        Total_number_of_students_in_school >> ${RUNLOG} 2>&1
#        #教职工人数
#        Number_of_staff >> ${RUNLOG} 2>&1
#        #生师比
#       Student_to_Teacher_Ratio >> ${RUNLOG} 2>&1
#        #辅导员人数
#        Number_of_Counselors >> ${RUNLOG} 2>&1
#        #辅导员生师比
#        Counselor_student_teacher_ratio >> ${RUNLOG} 2>&1
#         #专任教师数量
#         Number_of_full_time_teachers >> ${RUNLOG} 2>&1
#         #专任教师正高级职称人数
#         Full_time_teachers_are_high >> ${RUNLOG} 2>&1
#         #专任教师副高职称人数
#         Deputy_Senior_Teacher >> ${RUNLOG} 2>&1
#         #专任教师副高以上职称占比
#         The_proportion_of_full_time_teachers_above_deputy_senior >> ${RUNLOG} 2>&1
#         #专任教师具有研究生以上学历的教师人数
#         Teachers_with_postgraduate_education_or_above >> ${RUNLOG} 2>&1
#          #专任教师具有研究生以上学历的教师人数占比
#         The_proportion_of_teachers_with_postgraduate_education_or_above >> ${RUNLOG} 2>&1
#          #双师素质教师
#         Double_qualified_teachers >> ${RUNLOG} 2>&1
#         #双师素质教师占比
#         The_proportion_of_teachers_with_double_qualifications >> ${RUNLOG} 2>&1
#         #招生专业数量
#         Number_of_enrollment_Majors >> ${RUNLOG} 2>&1
#         #三年制专业数量
#         Quantity_of_three_year_Majors >> ${RUNLOG} 2>&1
#         #专业大类名称
#         Major_categories >> ${RUNLOG} 2>&1
#         #大类数量
#         Large_class_quantity >> ${RUNLOG} 2>&1
#         #二级学院名称 用、分开
#        Name_of_Secondary_Colleges_and_Departments >> ${RUNLOG} 2>&1
         #二级学院数量
         Coefficient_Quantity_of_Secondary_College >> ${RUNLOG} 2>&1
          #开设课程数量
         Number_of_courses_offered >> ${RUNLOG} 2>&1
        #理论类课程数量
         Number_of_theoretical_courses >> ${RUNLOG} 2>&1
         #理论课占比
         Proportion_of_theoretical_courses >> ${RUNLOG} 2>&1
         #理论+实践类课程数量
         Theory_and_Practice_Course >> ${RUNLOG} 2>&1
         #理论+实践类课程占比
         Proportion_of_theoretical_and_practical_courses >> ${RUNLOG} 2>&1
         #实践类课程数量
         Number_of_Practice_Courses >> ${RUNLOG} 2>&1
         #实践类课程占比
         Proportion_of_Practice_Courses >> ${RUNLOG} 2>&1
         #校企合作开发课程数
         School_Enterprise_Cooperative_Development_Course >> ${RUNLOG} 2>&1
         #规划总数
         Total_planning
          #已完成规划数量
         Planned_Quantity_Completed
         #未完成规划数量
         Uncompleted_Planning_Quantity
         #已完成任务数量
         Number_of_completed_tasks
         #规划任务总数
         Total_number_of_planning_tasks
         #除了学院层面外其他层面规划总数
         Total_number_of_plans_except_for_Colleges
         #除了学院层面外其他层面规划已完成
         Planning_at_all_levels_except_the_College_has_been_completed
         #除了学院层面外其他层面规划未完成
         Planning_at_all_levels_except_the_College_is_not_completed
         #五个层面质控点数量
         Number_of_Quality_Control_Points_at_Five_Levels
         #学院层面质控点
         Quality_Control_Points_at_College_Level
         #五个层面达标质控点
         Quality_Control_Points_for_Achieving_Standards_at_Five_Levels
         #除了学院层面外其他层面质控点总数
         Total_number_of_levels_other_than_college
         #所有任务总数
         Total_task
         #所有任务完成数量
         Number_of_tasks_completed
         #任务完成率
         Task_completion_rate
         #生师比状况
         Student_teacher_ratio
         #辅导员生师比状况
        The_Situation_of_Student_Teacher_Ratio_of_Counselors

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
      SEMESTERS=${j}
      echo $SEMESTER_YEARS"=="$SEMESTERS

        #教职工人数
        Number_of_staff >> ${RUNLOG} 2>&1
        #生师比
       Student_to_Teacher_Ratio >> ${RUNLOG} 2>&1

         #专任教师数量
         Number_of_full_time_teachers >> ${RUNLOG} 2>&1
         #专任教师正高级职称人数
         Full_time_teachers_are_high >> ${RUNLOG} 2>&1
         #专任教师副高职称人数
         Deputy_Senior_Teacher >> ${RUNLOG} 2>&1

         #专任教师副高以上职称占比
         The_proportion_of_full_time_teachers_above_deputy_senior >> ${RUNLOG} 2>&1
         #专任教师具有研究生以上学历的教师人数
         Teachers_with_postgraduate_education_or_above >> ${RUNLOG} 2>&1
          #专任教师具有研究生以上学历的教师人数占比
         The_proportion_of_teachers_with_postgraduate_education_or_above >> ${RUNLOG} 2>&1
          #双师素质教师
         Double_qualified_teachers >> ${RUNLOG} 2>&1
         #双师素质教师占比
         The_proportion_of_teachers_with_double_qualifications >> ${RUNLOG} 2>&1

         #生师比状况
         Student_teacher_ratio >> ${RUNLOG} 2>&1

      done
    done
}

#规划
function plan_getYearData() {
    find_mysql_data "
    select semester_year,semester,date_format(DATE_FORMAT(begin_time,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') as begin_time,
	 date_format(DATE_FORMAT(end_time,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') as end_time
	 from base_school_calendar_info where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;"| while read -a row
    do
      SEMESTER_YEARS=${row[0]}
      SEMESTERS=${row[1]}
      BEGIN_TIME=${row[2]}
      END_TIME=${row[3]}
      if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEAR IS NULL!"
      else
         echo "SEMESTER_YEAR IS NOT NULL"
         echo ${SEMESTER_YEARS}"=="${SEMESTERS}"=="${BEGIN_TIME}"=="${END_TIME}
         #规划总数
         Total_planning >> ${RUNLOG} 2>&1
          #已完成规划数量
         Planned_Quantity_Completed >> ${RUNLOG} 2>&1
         #未完成规划数量
         Uncompleted_Planning_Quantity >> ${RUNLOG} 2>&1
         #已完成任务数量
         Number_of_completed_tasks >> ${RUNLOG} 2>&1
         #规划任务总数
        Total_number_of_planning_tasks >> ${RUNLOG} 2>&1
         #除了学院层面外其他层面规划总数
        Total_number_of_plans_except_for_Colleges >> ${RUNLOG} 2>&1
         #除了学院层面外其他层面规划已完成
        Planning_at_all_levels_except_the_College_has_been_completed >> ${RUNLOG} 2>&1
         #除了学院层面外其他层面规划未完成
        Planning_at_all_levels_except_the_College_is_not_completed >> ${RUNLOG} 2>&1
         #五个层面质控点数量
        Number_of_Quality_Control_Points_at_Five_Levels >> ${RUNLOG} 2>&1
         #学院层面质控点
        Quality_Control_Points_at_College_Level >> ${RUNLOG} 2>&1
         #五个层面达标质控点
        Quality_Control_Points_for_Achieving_Standards_at_Five_Levels >> ${RUNLOG} 2>&1
         #除了学院层面外其他层面质控点总数
         Total_number_of_levels_other_than_college >> ${RUNLOG} 2>&1
         #所有任务总数
        Total_task >> ${RUNLOG} 2>&1
         #所有任务完成数量
        Number_of_tasks_completed >> ${RUNLOG} 2>&1
         #任务完成率
         Task_completion_rate >> ${RUNLOG} 2>&1

    fi
    done
}



#第一次调用"getYearData"将五横数据项近2年的1，2学期数据导入结果表中
#第一次调用"plan_getYearData"执行规划数据将最新数据导入结果集中
#第二次+以后执行"select_semester_year"/"plan_getYearData"
RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
getYearData >> ${RUNLOG} 2>&1
#select_semester_year >> ${RUNLOG} 2>&1
#plan_getYearData >> ${RUNLOG} 2>&1
finish






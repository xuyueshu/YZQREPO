#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_course_diagnosis_report

HIVE_DB=assurance
TARGET_TABLE=qu_course_diagnosis_report
function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：学年学期课程编号(关联表qu_course_diagnosis_report_record)',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                semester String comment '学期 1 第一学期 2 第二学期',
                course_code String comment '课程编号',
                course_name String comment '课程名称',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '课程诊断报告信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——课程诊断报告信息表：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and
    semester_year='${SEMESTER_YEARS}' and semester='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,semester,course_code,course_name,item_key,item_value,create_time'
    fn_log "导出数据--课程诊断报告信息表:${HIVE_DB}.${TARGET_TABLE}"
}

#课程类型
function Course_type() {
#exec_dir Course_type
HIVE_TABLE=Course_type
ITEM_KEY=KCLX
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 case when a.category='0' then '理论'
                      when a.category='1' then '实践'
                      when a.category='2' then '理论加实践'
                      when a.category='99' then '其他' end as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.major_course_record a
                 where a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTERS}'
            "
    fn_log "导入数据 —— 课程类型：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#是否是校企合作课程
function School_enterprise_cooperation() {
#exec_dir School_enterprise_cooperation
HIVE_TABLE=School_enterprise_cooperation
ITEM_KEY=SFXQHZKC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 case when a.is_corporate_development=1 then '是' else '否' end  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.major_course_record a
                    where a.semester='${SEMESTERS}'
                    and a.semester_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 是否是校企合作课程：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#是否精品课程
function Excellent_course() {
#exec_dir Excellent_course
HIVE_TABLE=Excellent_course
ITEM_KEY=SFJPKC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 case when a.is_pro='1' then '否' else '是' end as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.course_kpi_standard_state a
                 where a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTERS}'
            "
    fn_log "导入数据 —— 是否精品课程：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#课程组人数
function Number_of_course_groups() {
#exec_dir Number_of_course_groups
HIVE_TABLE=Number_of_course_groups
 ITEM_KEY=KCZRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (
               select
                a.course_code,
                a.course_name,
                count(a.teacher_code) as num
                from
                model.course_group_course_info a
                left join
                model.course_group_teacher_info b
                on a.course_group_code=b.course_group_code
                where semester_year='${SEMESTER_YEARS}'
            ) a
            "
    fn_log "导入数据 —— 课程组人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程组正高职称教师
function Professional_Teachers_in_Course_Group() {
exec_dir Professional_Teachers_in_Course_Group
HIVE_TABLE=Professional_Teachers_in_Course_Group
 ITEM_KEY=KCZZGZCJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                    select
                    a.course_code,
                    a.course_name,
                    count(b.teacher_code) as num
                    from
                    model.course_group_course_info a
                    left join
                    model.course_group_teacher_info b
                    on a.course_group_code=b.course_group_code
                    left join
                    model.basic_teacher_info c
                    on b.teacher_code = c.code and c.professional_title_level = '正高'
                    where b.semester_year='${SEMESTER_YEARS}'
                    group by a.course_code,
                    a.course_name
                 )a
            "
    fn_log "导入数据 —— 课程组正高职称教师：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}


#课程组副高职称教师
function Vice_Professional_Teachers_in_Course_Group() {
exec_dir Vice_Professional_Teachers_in_Course_Group
HIVE_TABLE=Vice_Professional_Teachers_in_Course_Group
 ITEM_KEY=KCZFGZCJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                    select
                    a.course_code,
                    a.course_name,
                    count(b.teacher_code) as num
                    from
                    model.course_group_course_info a
                    left join
                    model.course_group_teacher_info b
                    on a.course_group_code=b.course_group_code
                    left join
                    model.basic_teacher_info c
                    on b.teacher_code = c.code and c.professional_title_level = '副高'
                    where b.semester_year='${SEMESTER_YEARS}'
                    group by a.course_code,
                    a.course_name
                 )a
            "
    fn_log "导入数据 —— 课程组副高职称教师：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程组中级职称教师
function Intermediate_Professional_Title_Teachers_in_Course_Group() {
exec_dir Intermediate_Professional_Title_Teachers_in_Course_Group
HIVE_TABLE=Intermediate_Professional_Title_Teachers_in_Course_Group
 ITEM_KEY=KCZZJZCJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                    select
                    a.course_code,
                    a.course_name,
                    count(b.teacher_code) as num
                    from
                    model.course_group_course_info a
                    left join
                    model.course_group_teacher_info b
                    on a.course_group_code=b.course_group_code
                    left join
                    model.basic_teacher_info c
                    on b.teacher_code = c.code and c.professional_title_level = '中级'
                    where b.semester_year='${SEMESTER_YEARS}'
                    group by a.course_code,
                    a.course_name
                 )a
            "
    fn_log "导入数据 —— 课程组中级职称教师：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程组初级职称教师
function Teachers_with_Junior_Professional_Titles_in_Course_Group() {
exec_dir Teachers_with_Junior_Professional_Titles_in_Course_Group
HIVE_TABLE=Teachers_with_Junior_Professional_Titles_in_Course_Group
 ITEM_KEY=KCZCJZCJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                    select
                    a.course_code,
                    a.course_name,
                    count(b.teacher_code) as num
                    from
                    model.course_group_course_info a
                    left join
                    model.course_group_teacher_info b
                    on a.course_group_code=b.course_group_code
                    left join
                    model.basic_teacher_info c
                    on b.teacher_code = c.code and c.professional_title_level = '初级'
                    where b.semester_year='${SEMESTER_YEARS}'
                    group by a.course_code,
                    a.course_name
                 )a
            "
    fn_log "导入数据 —— 课程组初级职称教师：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程开课专业数量
function Number_of_courses_offered() {
#exec_dir Number_of_courses_offered
HIVE_TABLE=Number_of_courses_offered
 ITEM_KEY=KKZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                 select
                 count(a.major_code) as c,
                 a.course_code,
                 a.course_name
                 from model.major_course_record a
                 where a.is_open = 1 and a.semester_year = '${SEMESTER_YEARS}'
                 and a.semester = '${SEMESTERS}'
                 group by a.course_code,
                 a.course_name
                ) a

            "
    fn_log "导入数据 —— 课程开课专业数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程开课班级数量
function Number_of_classes_in_the_course() {
#exec_dir Number_of_classes_in_the_course
HIVE_TABLE=Number_of_classes_in_the_course
ITEM_KEY=KKBJSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 b.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.major_course_record a
              left join
              (
                  select
                   major_code,
                   count(code) as num
                   from
                   model.basic_class_info
                   where status=1 and
                   case when '${SEMESTERS}'=1 then grade = substr('${SEMESTER_YEARS}',1,4)
                   when '${SEMESTERS}'=2 then grade = substr('${SEMESTER_YEARS}',6,4) end
                   group by major_code
              ) b
              on a.major_code=b.major_code
              where a.is_open ='1'
              and a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTERS}'
            "
    fn_log "导入数据 —— 课程开课班级数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程学习人数
function Number_of_course_learners() {
#exec_dir Number_of_course_learners
HIVE_TABLE=Number_of_course_learners
 ITEM_KEY=KCXXRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                    select
                    sum(b.student_num) as c,
                    a.course_code,
                    a.course_name
                    from
                    model.major_course_record a
                    left join
                    model.basic_class_info b
                    on a.major_code=b.major_code
                    where a.is_open ='1'
                    and a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTERS}'
                    and b.grade BETWEEN substr('${SEMESTER_YEARS}',1,4) and  substr('${SEMESTER_YEARS}',6,4)
                    group by  a.course_code,
                    a.course_name
                ) a

            "
    fn_log "导入数据 —— 课程学习人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程平均分
function Average_course_score() {
#exec_dir Average_course_score
HIVE_TABLE=Average_course_score
ITEM_KEY=PJF
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 cast(avg(a.score) as decimal(9,2))  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               model.student_score_record a
               where  a.semester_year = '${SEMESTER_YEARS}'
               and a.semester = '${SEMESTERS}'
               group by a.course_code,a.course_name

            "
    fn_log "导入数据 —— 课程平均分：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程挂科人数
function Number_of_registered_students() {
#exec_dir Number_of_registered_students
HIVE_TABLE=Number_of_registered_students
 ITEM_KEY=GKRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.course_code as course_code,
                a.course_name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               (
                   select
                   count(a.code) as num,
                   a.course_name,
                   a.course_code
                   from model.student_score_record a
                   where a.score<60
                   and a.semester_year = '${SEMESTER_YEARS}'
                   and a.semester = '${SEMESTERS}'
                   group by a.course_name,
                   a.course_code
               ) a
            "
    fn_log "导入数据 —— 课程挂科人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程负责人编号
function Number_of_person_in_charge() {
#exec_dir Number_of_person_in_charge
HIVE_TABLE=Number_of_person_in_charge
ITEM_KEY=MANAGERNO
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.code as course_code,
                a.name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.teacher_code  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.basic_course_info a
              where a.open_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 课程负责人编号：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#课程负责人姓名
function Name_of_person_in_charge_name() {
#exec_dir Name_of_person_in_charge_name
HIVE_TABLE=Name_of_person_in_charge_name
 ITEM_KEY=MANAGERNAME
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.code)  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                a.code as course_code,
                a.name as course_name,
                '${ITEM_KEY}' as item_key,
                 a.teacher_name  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.basic_course_info a
              where a.open_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 课程负责人姓名：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

function select_semester_year(){
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
             #课程类型
            Course_type >> ${RUNLOG} 2>&1
             #是否是校企合作课程
            School_enterprise_cooperation >> ${RUNLOG} 2>&1
            #是否精品课程
            Excellent_course >> ${RUNLOG} 2>&1
            #课程组人数
            Number_of_course_groups >> ${RUNLOG} 2>&1
            #课程组正高职称教师
            Professional_Teachers_in_Course_Group >> ${RUNLOG} 2>&1
            #课程组副高职称教师
            Vice_Professional_Teachers_in_Course_Group >> ${RUNLOG} 2>&1
            #课程组中级职称教师
            Intermediate_Professional_Title_Teachers_in_Course_Group >> ${RUNLOG} 2>&1
            #课程组初级职称教师
            Teachers_with_Junior_Professional_Titles_in_Course_Group >> ${RUNLOG} 2>&1
            #课程开课专业数量
            Number_of_courses_offered >> ${RUNLOG} 2>&1
            #课程开课班级数量
            Number_of_classes_in_the_course >> ${RUNLOG} 2>&1
            #课程学习人数
             Number_of_course_learners >> ${RUNLOG} 2>&1
              #课程平均分
             Average_course_score >> ${RUNLOG} 2>&1
             #课程挂科人数
              Number_of_registered_students >> ${RUNLOG} 2>&1
            #课程负责人编号
            Number_of_person_in_charge >> ${RUNLOG} 2>&1
            #课程负责人名称
           Name_of_person_in_charge_name >> ${RUNLOG} 2>&1

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
             #课程类型
            Course_type >> ${RUNLOG} 2>&1
             #是否是校企合作课程
            School_enterprise_cooperation >> ${RUNLOG} 2>&1
            #是否精品课程
            Excellent_course >> ${RUNLOG} 2>&1
            #课程组人数
            Number_of_course_groups >> ${RUNLOG} 2>&1
            #课程组正高职称教师
            Professional_Teachers_in_Course_Group >> ${RUNLOG} 2>&1
            #课程组副高职称教师
            Vice_Professional_Teachers_in_Course_Group >> ${RUNLOG} 2>&1
            #课程组中级职称教师
            Intermediate_Professional_Title_Teachers_in_Course_Group >> ${RUNLOG} 2>&1
            #课程组初级职称教师
            Teachers_with_Junior_Professional_Titles_in_Course_Group >> ${RUNLOG} 2>&1
            #课程开课专业数量
            Number_of_courses_offered >> ${RUNLOG} 2>&1
            #课程开课班级数量
            Number_of_classes_in_the_course >> ${RUNLOG} 2>&1
            #课程学习人数
             Number_of_course_learners >> ${RUNLOG} 2>&1
              #课程平均分
             Average_course_score >> ${RUNLOG} 2>&1
             #课程挂科人数
              Number_of_registered_students >> ${RUNLOG} 2>&1
            #课程负责人编号
            Number_of_person_in_charge >> ${RUNLOG} 2>&1
            #课程负责人名称
           Name_of_person_in_charge_name >> ${RUNLOG} 2>&1
      done
    done
}

RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
#最新学年学期执行
select_semester_year >> ${RUNLOG} 2>&1
#需要最近两年的学年学期数据执行
#getYearData>> ${RUNLOG} 2>&1
finish




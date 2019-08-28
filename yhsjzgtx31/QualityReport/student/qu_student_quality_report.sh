#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_student_quality_report

# exec_dir方法：如果在单独执行下面方法时，可以根据需要将方法中的exec_dir方法放开进行查看日志，
# 如果统一执行全部方法时将日志在  ./logs/$0_`date +%Y-%m-%d`.log 2>&1 下
# getYearData方法 执行近两年的1，2学期的数据
# select_semester_year方法执行最新学年学期数据
# plan_getYearData方法执行规划数据

HIVE_DB=assurance
TARGET_TABLE=qu_student_quality_report
function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '学生层面质量报告'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——学生层面质量报告：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
     clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,item_key,item_value,create_time'
    fn_log "导出数据--学生层面质量报告:${HIVE_DB}.${TARGET_TABLE}"
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
                 concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.c as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                        select
                        count(code) as c
                        from app.basic_semester_student_info
                        where semester_year = '${SEMESTER_YEARS}'
                         and semester = '${SEMESTER}'
                   ) a
            "
    fn_log "导入数据 —— 在校生总人数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#男生总数
function Total_number_of_boys() {
#exec_dir Total_number_of_boys
HIVE_TABLE=Total_number_of_boys
 ITEM_KEY=NSZS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                         select
                         count(a.code) as c
                         from
                         app.basic_semester_student_info a left join model.basic_student_info b
                         on a.code=b.code
                         where
                         a.class_code=b.class_code
                         and a.major_code=b.major_code
                         and a.academy_code=b.academy_code
                         and  b.status='1'
                         and b.in_school ='1'
                         and b.sex = '1'
                         and a.semester_year = '${SEMESTER_YEARS}'
                         and a.semester = '${SEMESTER}'
                   ) a
            "
    fn_log "导入数据 —— 男生总数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#女生总数
function Total_number_of_girls() {
#exec_dir Total_number_of_girls
HIVE_TABLE=Total_number_of_girls
 ITEM_KEY=NVSZS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.c  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                         select
                         count(a.code) as c
                         from
                         app.basic_semester_student_info a left join model.basic_student_info b
                         on a.code=b.code
                         where
                         a.class_code=b.class_code
                         and a.major_code=b.major_code
                         and a.academy_code=b.academy_code
                         and  b.status='1'
                         and b.in_school ='1'
                         and b.sex = '2'
                         and a.semester_year = '${SEMESTER_YEARS}'
                          and a.semester = '${SEMESTER}'
                   ) a
            "
    fn_log "导入数据 —— 女生总数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#男女比
function Sex_ratio() {
#exec_dir Sex_ratio
HIVE_TABLE=Sex_ratio
 ITEM_KEY=NNSBL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT(cast((a.c/b.c)*100 as decimal(9,2)),'','%')as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                         select
                         count(a.code) as c
                         from
                         app.basic_semester_student_info a left join model.basic_student_info b
                         on a.code=b.code
                         where
                         a.class_code=b.class_code
                         and a.major_code=b.major_code
                         and a.academy_code=b.academy_code
                         and  b.status='1'
                         and b.in_school ='1'
                         and b.sex = '1'
                         and a.semester_year = '${SEMESTER_YEARS}'
                          and a.semester = '${SEMESTER}'
                   ) a,
                   (
                         select
                         count(a.code) as c
                         from
                         app.basic_semester_student_info a left join model.basic_student_info b
                         on a.code=b.code
                         where
                         a.class_code=b.class_code
                         and a.major_code=b.major_code
                         and a.academy_code=b.academy_code
                         and b.status='1'
                         and b.in_school ='1'
                         and b.sex = '2'
                         and a.semester_year = '${SEMESTER_YEARS}'
                          and a.semester = '${SEMESTER}'
                   ) b


            "
    fn_log "导入数据 —— 女生总数：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#专职辅导员数量
function Number_of_full_time_Counselors() {
#exec_dir Number_of_full_time_Counselors
HIVE_TABLE=Number_of_full_time_Counselors
 ITEM_KEY=ZZFDYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a. number  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                       select
                       count(a.code) as number
                       from  app.teacher_managerial_position_record a,
                       model.basic_teacher_info b
                       where a.code = b.code
                       and b.teacher_type = '校内专任教师'
                       and a.is_instructor ='1'
                       and a.semester_year = '${SEMESTER_YEARS}'
                   ) a


            "
    fn_log "导入数据 —— 专职辅导员数量：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#兼职辅导员数量
function Number_of_part_time_Counselors() {
#exec_dir Number_of_part_time_Counselors
HIVE_TABLE=Number_of_part_time_Counselors
 ITEM_KEY=JZFDYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.number  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                       select
                        count(a.code) as number
                        from  app.teacher_managerial_position_record a,
                        model.basic_teacher_info b
                        where a.code = b.code and
                       b.teacher_type in ('校内兼课教师','校外兼职老师','校外兼课老师')
                        and a.is_instructor ='0' and a.semester_year = '${SEMESTER_YEARS}'
                   ) a


            "
    fn_log "导入数据 —— 兼职辅导员数量：${HIVE_DB}.${HIVE_TABLE}"

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
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
              CONCAT(a.nums,':',b.number)as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                        select
                        count(b.code) as nums
                        from
                        app.basic_semester_student_info b
                        where b.semester_year = '${SEMESTER_YEARS}'
                   ) a,
                   (
                       select
                        count(a.code) as number
                        from  app.teacher_managerial_position_record a,
                        model.basic_teacher_info b
                        where a.code = b.code  and a.is_instructor ='1'
                        and a.semester_year = '${SEMESTER_YEARS}' and b.is_quit='2'
                   ) b



            "
    fn_log "导入数据 —— 辅导员生师比：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#研究生以上学历占(研究生以上学历/辅导员总数*100%)
function Postgraduate_degree_or_above_accounted_for() {
#exec_dir Postgraduate_degree_or_above_accounted_for
HIVE_TABLE=Postgraduate_degree_or_above_accounted_for
 ITEM_KEY=YJSYSXLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 nvl(CONCAT(cast((a.number/b.number)*100 as decimal(9,2)),'%'),0)  as item_value,

                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                         select
                         count(a.code) as number
                         from
                         app.teacher_managerial_position_record a,
                         model.basic_teacher_info b
                         where a.code = b.code and a.is_instructor ='1'
                         and b.is_quit='2' and b.education like '%研究生%'
                         and a.semester_year = '${SEMESTER_YEARS}'
                  ) a,
                 (
                       select
                        count(b.code) as number
                        from  app.teacher_managerial_position_record a,
                        model.basic_teacher_info b
                        where a.code = b.code  and a.is_instructor ='1'
                        and a.semester_year = '${SEMESTER_YEARS}' and b.is_quit='2'
                   ) b

            "
    fn_log "导入数据 —— 研究生以上学历占(研究生以上学历/辅导员总数*100%)：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}


#规划总数
function Total_planning() {
#exec_dir Total_planning
ITEM_KEY=GHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 ifnull(count(a.plan_no),0)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a where plan_layer = 'STUDENT'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#已完成规划数量
function Planned_Quantity_Completed() {
#exec_dir Planned_Quantity_Completed
ITEM_KEY=YWCGHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                pm_college_plan_info a
                where plan_status = 'YWC' and plan_layer = 'STUDENT'
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
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 pm_college_plan_info a where plan_status!='YWC'
                 and plan_layer = 'STUDENT'
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
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.task_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            left join
            tm_task_info b
            on a.plan_no = b.plan_no
            where a.plan_layer = 'STUDENT' and
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
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
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
                b.plan_layer = 'STUDENT' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#已完成规划任务总数
function Total_number_of_completed_planning_tasks() {
#exec_dir Total_number_of_completed_planning_tasks
ITEM_KEY=YWCGHRWZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
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
                b.plan_layer = 'STUDENT' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
                and a.task_status='YWC'
            "
    fn_log "导入数据 —— 已完成规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#规划任务完成率
function Total_number_of_completed_planning_tasks_rate() {
#exec_dir Total_number_of_completed_planning_tasks_rate
ITEM_KEY=GHRWWCL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                case when count(a.task_no)=0 then 0 else CONCAT(cast((count(case when a.task_status='YWC' then a.task_no end) /
                 count(a.task_no)) as decimal(9,2)),'','%') end  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            tm_task_info a left join
            pm_college_plan_info b
            on a.plan_no=b.plan_no where a.task_type = 'GHRW' and
            b.plan_layer = 'STUDENT' and b.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 规划任务完成率 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#层面质控点数量
function Number_of_Quality_Control_Points_at_Layer() {
#exec_dir Number_of_Quality_Control_Points_at_Layer
ITEM_KEY=ZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(quality_no)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               im_quality_info
               where index_layer = 'STUDENT'
               and create_time between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#目标达成率超过90%的质控点数量
function Goal_Achievement_Rate_Over_nine_Quantity() {
#exec_dir Goal_Achievement_Rate_Over_nine
ITEM_KEY=MBDCLCGBFZJSZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.num as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (
                select
                count(a.quality_no) as num
                from
                im_student_target_standard_record a
                where
                a.is_target='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a
            "
    fn_log "导入数据 —— 规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#标准达成率超过90%的质控点数量
function Standard_Achievement_Rate_Over_nine_Quantity_Quantity() {
#exec_dir Standard_Achievement_Rate_Over_nine_Quantity_Quantity
ITEM_KEY=BZDCLCGBFZJSZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(case when a.num > 90 then a.quality_no end ) as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (
                select
                count(a.quality_no) as num
                from
                im_student_target_standard_record a
                where
                a.is_standard='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a
            "
    fn_log "导入数据 —— 标准达成率超过90%的质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}

function select_semester_year() {

    SEMESTER_YEARS=`find_mysql_data "
    select semester_year from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
     "`
    SEMESTER=`find_mysql_data "
    select semester from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
    "`

    if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEARS IS NULL!"
    else
         echo "SEMESTER_YEARS IS NOT NULL"
         #开始依次执行
            #在校生总人数
        Total_number_of_students_in_school >> ${RUNLOG} 2>&1
        #男生总数
        Total_number_of_boys >> ${RUNLOG} 2>&1
		#女生总数
        Total_number_of_girls >> ${RUNLOG} 2>&1
		#男女比
        Sex_ratio >> ${RUNLOG} 2>&1
		#专职辅导员数量
        Number_of_full_time_Counselors >> ${RUNLOG} 2>&1
		#兼职辅导员数量
        Number_of_part_time_Counselors >> ${RUNLOG} 2>&1
		#辅导员生师比
        Counselor_student_teacher_ratio >> ${RUNLOG} 2>&1
		#研究生以上学历占(研究生以上学历/辅导员总数*100%)
        Postgraduate_degree_or_above_accounted_for >> ${RUNLOG} 2>&1

    fi

}

#五横
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
#        #在校生总人数
#        Total_number_of_students_in_school >> ${RUNLOG} 2>&1
#        #男生总数
#        Total_number_of_boys >> ${RUNLOG} 2>&1
#		#女生总数
#        Total_number_of_girls >> ${RUNLOG} 2>&1
#		#男女比
#        Sex_ratio >> ${RUNLOG} 2>&1
#		#专职辅导员数量
#        Number_of_full_time_Counselors >> ${RUNLOG} 2>&1
#		#兼职辅导员数量
#        Number_of_part_time_Counselors >> ${RUNLOG} 2>&1
		#辅导员生师比
        Counselor_student_teacher_ratio >> ${RUNLOG} 2>&1
#		#研究生以上学历占(研究生以上学历/辅导员总数*100%)
#        Postgraduate_degree_or_above_accounted_for >> ${RUNLOG} 2>&1
      done
    done
}

#规划方法
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
		#已完成规划任务总数
        Total_number_of_completed_planning_tasks >> ${RUNLOG} 2>&1
		#规划任务完成率
        Total_number_of_completed_planning_tasks_rate >> ${RUNLOG} 2>&1
		#层面质控点数量
        Number_of_Quality_Control_Points_at_Layer >> ${RUNLOG} 2>&1
		#目标达成率超过90%的质控点数量
        Goal_Achievement_Rate_Over_nine_Quantity >> ${RUNLOG} 2>&1
		#标准达成率超过90%的质控点数量
        Standard_Achievement_Rate_Over_nine_Quantity_Quantity >> ${RUNLOG} 2>&1
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

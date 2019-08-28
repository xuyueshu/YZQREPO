#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_major_quality_report
RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
HIVE_DB=assurance
TARGET_TABLE=qu_major_quality_report

# exec_dir方法：如果在单独执行下面方法时，可以根据需要将方法中的exec_dir方法放开进行查看日志，
# 如果统一执行全部方法时将日志在  ./logs/$0_`date +%Y-%m-%d`.log 2>&1 下
# getYearData方法 执行近两年的1，2学期的数据
# select_semester_year方法执行最新学年学期数据
# plan_getYearData方法执行规划数据

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '专业层面质量报告'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——专业层面质量报告：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}' ;"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,item_key,item_value,create_time'
    fn_log "导出数据--专业诊断报告信息表:${HIVE_DB}.${TARGET_TABLE}"
}
#招生专业数量
function Number_enrollment_Majors() {
#exec_dir Number_enrollment_Majors
HIVE_TABLE=Number_enrollment_Majors
ITEM_KEY=ZSZYS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.enroll_student_major_count  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            app.major_total_info a
            where a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 招生专业数量表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#院系名称  用、分隔  举两个例子即可
function Name_of_Department() {
exec_dir Name_of_Department
HIVE_TABLE=Name_of_Department
ITEM_KEY=YXMC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT_WS(',', COLLECT_LIST(a.academy_name))  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
           (
                select distinct a.academy_name from
                 app.basic_semester_student_info a left join  model.basic_student_info b
                 on a.code=b.code and a.major_code=b.major_code
                 where a.semester_year = '${SEMESTER_YEARS}'
                 limit 2
            ) a
            "
    fn_log "导入数据 —— 院系名称：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#YXSL 院系数量
function Number_of_Department() {
exec_dir Number_of_Department
HIVE_TABLE=Number_of_Department
ITEM_KEY=YXSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (select count(distinct academy_name) as num  from
            app.basic_semester_student_info a where a.semester_year = '${SEMESTER_YEARS}'
            ) a
            "
    fn_log "导入数据 —— 院系数量表：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#ZYDLMC    专业大类名称  用、分隔  举两个例子即可
function Names_of_Professional_Categories() {
exec_dir Names_of_Professional_Categories
HIVE_TABLE=Names_of_Professional_Categories
ITEM_KEY=ZYDLMC
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
    concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
    '${SEMESTER_YEARS}' as semester_year,
    '${ITEM_KEY}' as item_key,
    concat_ws(',',collect_set(case when a.discipline_type='LGNY' then '理工农医类'
                                   when a.discipline_type='RWSK' then '人文社科类'
                                   when a.discipline_type='QT' then '其他类' else '' end)) as item_value,
    FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
from
    (select discipline_type from model.basic_major_info
     where semester_year = '${SEMESTER_YEARS}'
     group by discipline_type
    ) a
            "
    fn_log "导入数据 —— 专业大类名称：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#大类数量
function Large_class_quantity() {
exec_dir Large_class_quantity
HIVE_TABLE=Large_class_quantity
 ITEM_KEY=DLSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.discipline_type) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                     model.basic_major_info a
                     where a.semester_year = '${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 大类数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#  现代学徒制试点专业数量
function Apprentice_major() {
exec_dir Apprentice_major
HIVE_TABLE=Apprentice_major
ITEM_KEY=XDXTZSDZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.major_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    app.major_plan_student a
                    where a.type='2' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 现代学徒制试点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
# 国家级重点专业数量
function Number_National_Key_Specialties() {
exec_dir Number_National_Key_Specialties
HIVE_TABLE=Number_National_Key_Specialties
ITEM_KEY=GJJZDZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_major_info a
                    where a.basic_type='GJJZD' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 国家级重点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#省级重点专业数量
function Number_Provincial_key_points() {
exec_dir Number_Provincial_key_points
HIVE_TABLE=Number_Provincial_key_points
ITEM_KEY=SJZDZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_major_info a
                    where a.basic_type='SJZD' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 省级重点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#DSJZDZY地市级重点专业
#地市级重点专业数量
function import_table_DSJZDZY() {
exec_dir import_table_DSJZDZY
HIVE_TABLE=import_table_DSJZDZY
ITEM_KEY=DIJZDZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_major_info a
                    where a.basic_type='DSJZDZY' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 校级重点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#DSJTSZY地市级特色专业
function import_table_DSJTSZY() {
exec_dir import_table_DSJTSZY
HIVE_TABLE=import_table_DSJTSZY
ITEM_KEY=DIJTSZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_major_info a
                    where a.basic_type='DIJTSZYSL' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 校级重点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}


#校级重点专业数量
function Number_school_level_points() {
exec_dir Number_school_level_points
HIVE_TABLE=Number_school_level_points
ITEM_KEY=XJZDZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_major_info a
                    where a.basic_type='XYJZD' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 校级重点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#国家级特色专业数量
function Number_National_Key_characteristic() {
exec_dir Number_National_Key_characteristic
HIVE_TABLE=Number_National_Key_characteristic
ITEM_KEY=GJJTSZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                    model.basic_major_info a
                    where a.basic_type='GJJTS' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 地市级重点专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#省级特色专业数量
function Number_Provincial_key_characteristic() {
exec_dir Number_Provincial_key_characteristic
HIVE_TABLE=Number_Provincial_key_characteristic
ITEM_KEY=SJTSZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                     model.basic_major_info a
                    where a.basic_type='SJTS' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 省级特色专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#校级特色专业数量
function Number_school_level_characteristic() {
exec_dir Number_school_level_characteristic
HIVE_TABLE=Number_school_level_characteristic
ITEM_KEY=XJTSZYSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')   as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(distinct a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                     model.basic_major_info a
                    where a.basic_type='XYJTS' and a.semester_year='${SEMESTER_YEARS}'
            "
    fn_log "导入数据 —— 校级特色专业数量：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#规划总数（专业层面的）
function import_table_GHZS() {
#exec_dir qu_maior_quality_GHZS
ITEM_KEY=GHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(0)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where a.plan_layer = 'G_MAJOR' and a.status = 'NORMAL' and
            a.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}

#完成规划数量（专业层面的）
function import_table_WCGHSL() {
#exec_dir qu_major_quality_WCGHSL
ITEM_KEY=WCGHSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
        INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(0)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where a.plan_layer = 'G_MAJOR' and status = 'NORMAL'
            and a.plan_status='YWC' and a.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#未完成规划数量（专业层面的）
function import_table_WWCGHSL() {
#exec_dir qu_major_quality_WWCGHSL
ITEM_KEY=WWCGHSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','MAJOR') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.first_plan_no)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where a.plan_layer = 'G_MAJOR' and status = 'NORMAL'
            and a.plan_status!='YWC' and a.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 未完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#已完成任务数量（专业层面的）
function import_table_YWCRWSL() {
#exec_dir qu_major_quality_YWCRWSL
ITEM_KEY=YWCRWSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','MAJOR') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(b.task_no)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            left join
            tm_task_info b
            on a.plan_no = b.plan_no
            where a.plan_layer = 'G_MAJOR' and
            b.task_status = 'YWC' and
            b.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 已完成任务数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}
#规划任务总数
function import_table_GHHRWZS() {
#exec_dir qu_major_quality_GHHRWZS
ITEM_KEY=GHHRWZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
          INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
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
                b.plan_layer = 'G_MAJOR' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}
#YWCGHRWZS 已完成规划任务总数
function import_table_YWCGHRWZS() {
#exec_dir qu_major_quality_YWCGHRWZS
ITEM_KEY=YWCGHRWZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR')  as report_no,
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
                b.plan_layer = 'G_MAJOR' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
                and a.task_status='YWC'
            "
    fn_log "导入数据 —— 已完成规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}
#规划任务完成率
function import_table_GHRWWCL() {
#exec_dir qu_major_quality_GHRWWCL
ITEM_KEY=GHRWWCL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
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
            b.plan_layer = 'MAJOR' and b.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 规划任务完成率 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



}
#专业层面质控点数量
function import_table_ZKDSL() {
#exec_dir qu_major_quality_ZKDSL
ITEM_KEY=ZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
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
               where index_layer = 'MAJOR'
               and create_time between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#目标达成率超过90%的质控点数量
function import_table_MBDCLCGBFZJSZKDSL() {
#exec_dir qu_major_quality_MBDCLCGBFZJSZKDSL
ITEM_KEY=MBDCLCGBFZJSZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
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
                im_major_target_standard_record a
                where
                a.is_target='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a
            "
    fn_log "导入数据 —— 目标达成率超过90%的质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

#标准达成率超过90%的质控点数量
function import_table_BZDCLCGBFZJSZKDSL() {
#exec_dir qu_major_quality_BZDCLCGBFZJSZKDSL
ITEM_KEY=BZDCLCGBFZJSZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}' and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
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
                im_major_target_standard_record a
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
    SEMESTERS=`find_mysql_data "
    select semester from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
    "`

    if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEAR IS NULL!"
    else
         echo "SEMESTER_YEAR IS NOT NULL"
           #开始依次执行
            #招生专业数量
            Number_enrollment_Majors >> ${RUNLOG} 2>&1
            #院系名称  用、分隔  举两个例子即可
            Name_of_Department >> ${RUNLOG} 2>&1
            #院系数量
            Number_of_Department >> ${RUNLOG} 2>&1
            #专业大类名称  用、分隔  举两个例子即可
            Names_of_Professional_Categories >> ${RUNLOG} 2>&1
            #大类数量
            Large_class_quantity >> ${RUNLOG} 2>&1
            #现代学徒制试点专业数量
            Apprentice_major >> ${RUNLOG} 2>&1
            #国家级重点专业数量
            Number_National_Key_Specialties >> ${RUNLOG} 2>&1
            #省级重点专业数量
            Number_Provincial_key_points >> ${RUNLOG} 2>&1
            #地市级重点专业数量
            import_table_DSJZDZY >> ${RUNLOG} 2>&1
            #DSJTSZY地市级特色专业
            import_table_DSJTSZY >> ${RUNLOG} 2>&1
            #校级重点专业数量
            Number_school_level_points >> ${RUNLOG} 2>&1
            #国家级特色专业数量
            Number_National_Key_characteristic >> ${RUNLOG} 2>&1
            #省级特色专业数量
            Number_Provincial_key_characteristic >> ${RUNLOG} 2>&1
            #校级特色专业数量
            Number_school_level_characteristic >> ${RUNLOG} 2>&1

    fi

}
function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
    for((i=1;i<=2;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      SEMESTER_YEARS=${PRE_YEAR}"-"${NOW_YEAR}
      for((j=1;j<=2;j++));
      do
      SEMESTERS=${j}
      echo $SEMESTER_YEARS"=="$SEMESTERS
            #招生专业数量
            Number_enrollment_Majors >> ${RUNLOG} 2>&1
            #院系名称  用、分隔  举两个例子即可
            Name_of_Department >> ${RUNLOG} 2>&1
            #院系数量
            Number_of_Department >> ${RUNLOG} 2>&1
            #专业大类名称  用、分隔  举两个例子即可
            Names_of_Professional_Categories >> ${RUNLOG} 2>&1
            #大类数量
            Large_class_quantity >> ${RUNLOG} 2>&1
            #现代学徒制试点专业数量
            Apprentice_major >> ${RUNLOG} 2>&1
            #国家级重点专业数量
            Number_National_Key_Specialties >> ${RUNLOG} 2>&1
            #省级重点专业数量
            Number_Provincial_key_points >> ${RUNLOG} 2>&1
            #地市级重点专业数量
            import_table_DSJZDZY >> ${RUNLOG} 2>&1
            #DSJTSZY地市级特色专业
            import_table_DSJTSZY >> ${RUNLOG} 2>&1
            #校级重点专业数量
            Number_school_level_points >> ${RUNLOG} 2>&1
            #国家级特色专业数量
            Number_National_Key_characteristic >> ${RUNLOG} 2>&1
            #省级特色专业数量
            Number_Provincial_key_characteristic >> ${RUNLOG} 2>&1
            #校级特色专业数量
            Number_school_level_characteristic >> ${RUNLOG} 2>&1

      done
    done
}
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
        import_table_GHZS >> ${RUNLOG} 2>&1
        #完成规划数量
        import_table_WCGHSL >> ${RUNLOG} 2>&1
        #未完成规划数量
        import_table_WWCGHSL >> ${RUNLOG} 2>&1
        #已完成任务数量
        import_table_YWCRWSL >> ${RUNLOG} 2>&1
        #规划任务总数
        import_table_GHHRWZS >> ${RUNLOG} 2>&1
        #已完成规划任务总数
        import_table_YWCGHRWZS >> ${RUNLOG} 2>&1
        #规划任务完成率
        import_table_GHRWWCL >> ${RUNLOG} 2>&1
        #专业层面质控点数量
        import_table_ZKDSL >> ${RUNLOG} 2>&1
        #目标达成率超过90%的质控点数量
        import_table_MBDCLCGBFZJSZKDSL >> ${RUNLOG} 2>&1
        #标准达成率超过90%的质控点数量
        import_table_BZDCLCGBFZJSZKDSL >> ${RUNLOG} 2>&1

    fi
    done
}

#第一次调用"getYearData"将五横数据项近2年的1，2学期数据导入结果表中
#第一次调用"plan_getYearData"执行规划数据将最新数据导入结果集中
#第二次+以后执行"select_semester_year"/"plan_getYearData"
RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
getYearData >> ${RUNLOG} 2>&1
select_semester_year >> ${RUNLOG} 2>&1
plan_getYearData >> ${RUNLOG} 2>&1
finish


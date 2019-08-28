#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_teacher_quality_report
HIVE_DB=assurance
TARGET_TABLE=qu_teacher_quality_report

# exec_dir方法：如果在单独执行下面方法时，可以根据需要将方法中的exec_dir方法放开进行查看日志，
# 如果统一执行全部方法时将日志在  ./logs/$0_`date +%Y-%m-%d`.log 2>&1 下
# getYearData方法 执行近两年的1，2学期的数据
# select_semester_year方法执行最新学年学期数据

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '教师层面质量报告'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——教师层面质量报告：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
   clear_mysql_data "delete from qu_teacher_quality_report where item_key = '${ITEM_KEY}'
and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,item_key,item_value,create_time'
    fn_log "导出数据--教师层面质量报告:${HIVE_DB}.${TARGET_TABLE}"
}

#专任教师数量
function import_table_ZRJSSL(){
HIVE_TABLE=qu_teacher_quality_report_ZRJSSL
ITEM_KEY=ZRJSSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where a.teacher_type like '%专任%'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#正高职称人数
function import_table_ZGZCRS(){
#exec_dir qu_teacher_quality_ZGZCRS
HIVE_TABLE=qu_teacher_quality_ZGZCRS
ITEM_KEY=ZGZCRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%' and
                  a.professional_title_level='正高'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'

            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#副高职称人数
function import_table_FGZCRS() {
#exec_dir qu_teacher_quality_FGZCRS
HIVE_TABLE=qu_teacher_quality_FGZCRS
ITEM_KEY=FGZCRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%' and
                  a.professional_title_level='副高'
                  and a.is_quit='2'

                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#副高及以上职称占专任教师比例（副高及以上职称人数/专任教师数量*100%）
function import_table_FGYSZZRBL() {
#exec_dir qu_teacher_quality_FGYSZZRBL
HIVE_TABLE=qu_teacher_quality_FGYSZZRBL
ITEM_KEY=FGJYSZCZZRJSBL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT(cast(count(case when a.professional_title_level = '正高'  then a.professional_title_level
                  when a.professional_title_level = '副高'
                 then a.professional_title_level end) /count(a.code)*100 as decimal(9,2)) ,'','%')  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#具有研究生以上学历的教师人数
function import_table_YJSYSRS() {
#exec_dir qu_teacher_quality_YJSYSRS
HIVE_TABLE=qu_teacher_quality_YJSYSRS
ITEM_KEY=JYYSYSXLDJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'

                  and  a.education in ('硕士研究生','博士研究生')

            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#研究生以上学历的教师人数占到专任教师比例（具有研究生以上学历的教师人数/专任教师数量*100%）
function import_table_YJSYSRSJZRBL() {
#exec_dir qu_teacher_quality_YJSYSRSJZRBL
HIVE_TABLE=qu_teacher_quality_YJSYSRSJZRBL
ITEM_KEY=YJSYSXLDJSRSZDZRJSBL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT(cast(count(case when a.education = '硕士研究生'  then a.education
                  when a.education = '博士研究生'
                 then a.education end) /count(a.code)*100 as decimal(9,2)) ,'','%')  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#双师素质教师人数
function import_table_SSSZJSRS() {
#exec_dir qu_teacher_quality_SSSZJSRS
HIVE_TABLE=qu_teacher_quality_SSSZJSRS
ITEM_KEY=SSSZJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%'
                  and is_double_professionally = '1'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'

            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#双师素质教师人数占专任教师比例（双师素质教师人数/专任教师数量*100%）
function import_table_SSSZJSRSZZRJSBL() {
#exec_dir qu_teacher_quality_SSSZJSRSZZRJSBL
HIVE_TABLE=qu_teacher_quality_SSSZJSRSZZRJSBL
ITEM_KEY=SSSZJSRSZZRJSBL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT(cast(count(case when is_double_professionally = '1'  then a.is_double_professionally end)
                 /count(a.code)*100 as decimal(9,2)) ,'','%')  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type like '%专任%'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#校外兼职教师人数
function import_table_XWJZJSRS() {
#exec_dir qu_teacher_quality_XWJZJSRS
HIVE_TABLE=qu_teacher_quality_XWJZJSRS
ITEM_KEY=XWJZJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type ='校外兼课教师'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#校外兼职教师具有正高级职称人数
function import_table_XWJZJZGRS() {
#exec_dir qu_teacher_quality_XWJZJZGRS
HIVE_TABLE=qu_teacher_quality_XWJZJZGRS
ITEM_KEY=XWJZJSJYZGJZCRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type = '校外兼课教师'
                  and a.professional_title_level = '正高'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#校外兼职教师具有副高职称人数
function import_table_XWJZJFGRS() {
#exec_dir qu_teacher_quality_XWJZJFGRS
HIVE_TABLE=qu_teacher_quality_XWJZJFGRS
ITEM_KEY=XWJZJSJYFGJZCRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type ='校外兼课教师'
                  and a.professional_title_level = '副高'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#校外兼职教师人数副高及以上职称占校外兼职教师比例  副高及以上职称人数/校外兼职教师数量*100%
function import_table_XWJZJFGJYSRS() {
#exec_dir qu_teacher_quality_XWJZJFGJYSRS
HIVE_TABLE=qu_teacher_quality_XWJZJFGJYSRS
ITEM_KEY=XWJZJSRSFGJYSZCZXWJZJSBL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
               concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                CONCAT(cast(count(case when a.professional_title_level = '正高'  then a.professional_title_level
                  when a.professional_title_level = '副高'
                 then a.professional_title_level end) /count(a.code)*100 as decimal(9,2)) ,'','%')  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type ='校外兼课教师'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'


            "
    fn_log "导入数据 —— 教师层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#校外兼职教师研究生以上学历的教师人数
function import_table_XWJZJSYJSYSXLJSRS() {
#exec_dir qu_teacher_quality_XWJZJSYJSYSXLJSRS
HIVE_TABLE=qu_teacher_quality_XWJZJSYJSYSXLJSRS
ITEM_KEY=XWJZJSYJSYSXLJSRS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.basic_teacher_info a where
                  a.teacher_type = '校外兼课教师'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'

                  and a.education in ('硕士研究生','博士研究生')

            "
    fn_log "导入数据 —— 校外兼职教师研究生以上学历的教师人数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#校外兼职教师研究生以上学历教师占校外兼职教师比例【具有研究生以上学历的教师人数/专任教师数量*100%】
function import_table_XWJZYJSZJZSBL() {
#exec_dir qu_teacher_quality_XWJZYJSZJZSBL
HIVE_TABLE=qu_teacher_quality_XWJZYJSZJZSBL
ITEM_KEY=XWJZJSYJSYSXLJSRSZXWJZJSBL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 CONCAT(cast(count(case when a.professional_title_level = '硕士研究生'  then a.professional_title_level
                  when a.professional_title_level = '博士研究生'
                 then a.professional_title_level end) /count(a.code)*100 as decimal(9,2)) ,'','%')  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.basic_teacher_info a where
                  a.teacher_type = '校外兼课教师'
                  and a.is_quit='2'
                  and a.semester_year = '${SEMESTER_YEARS}'

            "
    fn_log "导入数据 —— 校外兼职教师研究生以上学历教师占校外兼职教师比例 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#教师层面规划总数
function import_table_JSCMGHZS() {
#exec_dir qu_teacher_quality_JSCMGHZS
ITEM_KEY=JSCMGHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
        INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.plan_no)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where plan_layer = 'TEACHER' and status = 'NORMAL'
            and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 教师层面规划总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}
#已完成规划数量
function import_table_YWCGHSL() {
#exec_dir qu_teacher_quality_YWCGHSL
ITEM_KEY=YWCGHSL
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
                where plan_status = 'YWC' and plan_layer = 'TEACHER'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 已完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}

#未完成规划数量
function import_table_WWCGHSL() {
#exec_dir qu_teacher_quality_WWCGHSL
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
                 and plan_layer = 'TEACHER'
                 and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 未完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}
#共完成任务数量
function import_table_GWCRWSL() {
#exec_dir qu_teacher_quality_GWCRWSL
ITEM_KEY=GWCRWSL
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
            where a.plan_layer = 'TEACHER' and
            b.task_status = 'YWC' and
            b.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 共完成任务数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



}
#教师层面规划任务总数
function import_table_JSCMGHRSZS() {
#exec_dir qu_teacher_quality_JSCMGHRSZS
ITEM_KEY=JSCMGHRSZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
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
                b.plan_layer = 'TEACHER' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 教师层面规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}

#规划任务完成率  已完成教师层面规划任务总数/教师层面规划任务总数*100%
function import_table_GHRWWCL() {
#exec_dir qu_teacher_quality_GHRWWCL
ITEM_KEY=GHRWWCL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                case when count(a.task_no)=0 then 0
                else
                 CONCAT(cast(count(case when a.task_status='YWC' then a.task_no end) /
                 count(a.task_no)*100 as decimal(9,2)),'','%')  end as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            tm_task_info a
            left join
            pm_college_plan_info b
            on a.plan_no=b.plan_no
            where a.task_type = 'GHRW' and b.plan_layer = 'TEACHER'
            and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划任务完成率 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



}

#教师层面质控点数量
function import_table_JSCMZKDSL() {
#exec_dir qu_teacher_quality_JSCMZKDSL
ITEM_KEY=JSCMZKDSL
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
               where index_layer = 'TEACHER'
               and create_time between '${BEGIN_TIME}' and '${END_TIME}'


            "
    fn_log "导入数据 ——教师层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



}

#教师层面目标达成率超过90%的质控点数量
function import_table_JSCMMBDCLCGBFZJSDZKDSL() {
#exec_dir qu_teacher_quality_JSCMMBDCLCGBFZJSDZKDSL
ITEM_KEY=JSCMMBDCLCGBFZJSDZKDSL
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
                im_teacher_target_standard_record a
                where
                a.is_target='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a

            "
    fn_log "导入数据 ——教师层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



}

#教师层面标准达成率超过90%的质控点数量
function import_table_JSCMBZDCLCGBFZJSDZKDSL() {
#exec_dir qu_teacher_quality_JSCMBZDCLCGBFZJSDZKDSL
ITEM_KEY=JSCMBZDCLCGBFZJSDZKDSL
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
                im_teacher_target_standard_record a
                where
                a.is_standard='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a

            "
    fn_log "导入数据 ——教师层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

#五横数据项最新数据
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
       import_table_ZRJSSL >> ${RUNLOG} 2>&1
        #正高职称人数
        import_table_ZGZCRS >> ${RUNLOG} 2>&1
        #副高职称人数
        import_table_FGZCRS >> ${RUNLOG} 2>&1
        #副高及以上职称占专任教师比例
        import_table_FGYSZZRBL >> ${RUNLOG} 2>&1
        #具有研究生以上学历的教师人数
        import_table_YJSYSRS >> ${RUNLOG} 2>&1
        #研究生以上学历的教师人数占到专任教师比例
        import_table_YJSYSRSJZRBL >> ${RUNLOG} 2>&1
        #双师素质教师人数
         import_table_SSSZJSRS >> ${RUNLOG} 2>&1
         #双师素质教师人数占专任教师比例（
        import_table_SSSZJSRSZZRJSBL >> ${RUNLOG} 2>&1
         # 校外兼职教师人数
        import_table_XWJZJSRS >> ${RUNLOG} 2>&1
        #校外兼职教师具有正高级职称人数
        import_table_XWJZJZGRS >> ${RUNLOG} 2>&1
        #校外兼职教师具有副高职称人数
        import_table_XWJZJFGRS >> ${RUNLOG} 2>&1
        #校外兼职教师人数副高及以上职称占校外兼职教师比例  副高及以上职称人数/校外兼职教师数量*100%
        import_table_XWJZJFGJYSRS >> ${RUNLOG} 2>&1
        #校外兼职教师研究生以上学历的教师人数
        import_table_XWJZJSYJSYSXLJSRS >> ${RUNLOG} 2>&1
    fi
}
#五横数据项近2年的1，2学期
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
        import_table_ZRJSSL >> ${RUNLOG} 2>&1
        #正高职称人数
        import_table_ZGZCRS >> ${RUNLOG} 2>&1
        #副高职称人数
        import_table_FGZCRS >> ${RUNLOG} 2>&1
        #副高及以上职称占专任教师比例
        import_table_FGYSZZRBL >> ${RUNLOG} 2>&1
        #具有研究生以上学历的教师人数
        import_table_YJSYSRS >> ${RUNLOG} 2>&1
        #研究生以上学历的教师人数占到专任教师比例
        import_table_YJSYSRSJZRBL >> ${RUNLOG} 2>&1
        #双师素质教师人数
         import_table_SSSZJSRS >> ${RUNLOG} 2>&1
         #双师素质教师人数占专任教师比例（
        import_table_SSSZJSRSZZRJSBL >> ${RUNLOG} 2>&1
         # 校外兼职教师人数
        import_table_XWJZJSRS >> ${RUNLOG} 2>&1
        #校外兼职教师具有正高级职称人数
        import_table_XWJZJZGRS >> ${RUNLOG} 2>&1
        #校外兼职教师具有副高职称人数
        import_table_XWJZJFGRS >> ${RUNLOG} 2>&1
        #校外兼职教师人数副高及以上职称占校外兼职教师比例  副高及以上职称人数/校外兼职教师数量*100%
        import_table_XWJZJFGJYSRS >> ${RUNLOG} 2>&1
        #校外兼职教师研究生以上学历的教师人数
        import_table_XWJZJSYJSYSXLJSRS >> ${RUNLOG} 2>&1

      done
    done
}
#规划方法最新数据
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
        #教师层面规划总数
        import_table_JSCMGHZS >> ${RUNLOG} 2>&1
        #已完成规划数量
        import_table_YWCGHSL >> ${RUNLOG} 2>&1
        #未完成规划数量
        import_table_WWCGHSL >> ${RUNLOG} 2>&1
        #共完成任务数量
        import_table_GWCRWSL >> ${RUNLOG} 2>&1
        #教师层面规划任务总数
        import_table_JSCMGHRSZS >> ${RUNLOG} 2>&1
        #规划任务完成率
        import_table_GHRWWCL >> ${RUNLOG} 2>&1
        #教师层面质控点数量
        import_table_JSCMZKDSL >> ${RUNLOG} 2>&1
        #教师层面目标达成率超过90%的质控点数量
        import_table_JSCMMBDCLCGBFZJSDZKDSL >> ${RUNLOG} 2>&1
        #教师层面标准达成率超过90%的质控点数量
        import_table_JSCMBZDCLCGBFZJSDZKDSL >> ${RUNLOG} 2>&1
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

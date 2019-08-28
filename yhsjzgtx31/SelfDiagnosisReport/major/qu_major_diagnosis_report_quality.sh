#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_major_diagnosis_report_quality

HIVE_DB=assurance
TARGET_TABLE=qu_major_diagnosis_report_quality

# quality_name String comment '质控点名称',
# diagnosis_result  String comment '诊断结果',
# diagnosis_reason String comment '原因分析 text(默认为空)',
# diagnosis_function String comment '改进措施 text(默认为空)',
# diagnosis_effect String comment '改进成效 text(默认为空)',
# create_time String comment '创建时间'

function import_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    clear_mysql_data "
                set names utf8;
                insert into  ${TARGET_TABLE}
                (report_no,quality_name,diagnosis_result,create_time)
                      select
                        concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_no) as report_no,
                        a.quality_name as  quality_name,
                        case when a.is_standard='YES' then '达标' else '未达标' end  as  diagnosis_result ,
                        FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
                      from
                       im_major_target_standard_record a
                       where a.semester_year='${SEMESTER_YEARS}'
    "
}

#判断并执行
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
        import_table

    fi

}

select_semester_year
finish






#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_college_quality_report_plan_task
#学院所有任务情况

HIVE_DB=assurance
TARGET_TABLE=qu_college_quality_report_plan_task

function import_table_report_no() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         INSERT INTO ${TARGET_TABLE}(report_no,task_type,task_num,task_rate,create_time)
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                a.task_type as task_type,
                count(a.task_no) as task_num,
                case when count(task_no)=0 then 0
                else
                cast(sum(case when task_status ='YWC' then 1 else 0 end) / count(task_no) as decimal(8,1))
                end as task_rate,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                from
                tm_task_info a
                where a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
                and a.task_delete='NORMAL'
                group by a.task_type
            "
    fn_log "导入数据 —— 学院所有任务情况：${HIVE_DB}.${TARGET_TABLE}"
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
         import_table_report_no >> ${RUNLOG} 2>&1
    fi
    done

}

RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
plan_getYearData >> ${RUNLOG} 2>&1
finish


#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_teacher_diagnosis_report_task

HIVE_DB=assurance
TARGET_TABLE=qu_teacher_diagnosis_report_task

function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    clear_mysql_data "
                    set names utf8;
                    INSERT INTO ${TARGET_TABLE}
                       (report_no,task_name,task_type,task_roler,finish_info,create_time)
                      select
                        concat('${SEMESTER_YEARS}','${SEMESTERS}',a.person_no) as report_no,
                        a.task_name as task_name,
                        a.task_type as task_type,
                        a.task_roler as task_roler,
                        a.finish_info as finish_info,
                        FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
                      from
                        (
                            select
                             a.person_no,
                             b.task_name,
                             b.task_type,
                             a.person_type as task_roler,
                             case when a.finish_status='JXZ' then '进行中'
                                  when a.finish_status='YTJ' then '已提交' end as finish_info
                             from
                             tm_task_person a left join
                             tm_task_info b on a.task_no = b.task_no
                             left join
                             pm_college_plan_info c on b.plan_no=c.plan_no
                             where c.plan_layer='G_TEACHER' and b.task_delete='NORMAL'
                             and c.status='NORMAL'
                             and substr(a.create_time,1,7) BETWEEN '${BEGIN_TIME}' and '${END_TIME}'
                         ) a
    "
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
         export_table
    fi
    done

}

plan_getYearData
finish

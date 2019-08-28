#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_course_quality_report_plan_task
#课程整体规划任务情况

HIVE_DB=assurance
TARGET_TABLE=qu_course_quality_report_plan_task

# report_no String comment '报告编号',
# task_name  String comment '任务名称',
# manager_name String comment '负责人',
# department_name String comment '负责部门',
# task_finish String comment '任务完成情况  已完成  进行中  等',
# create_time String comment '创建时间'

function import_table_report_no() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
          set names utf8;
          INSERT INTO ${TARGET_TABLE}(report_no,task_name,manager_name,department_name,
            task_finish,create_time)
             select
                distinct
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                a.task_name  as task_name,
                a.manager_name  as manager_name,
                a.department_name as department_name,
                case when a.task_status='DSH' then '待审核'
                     when a.task_status='SHZ' then '审核中'
                     when a.task_status='SHWTG' then '审核未通过'
                     when a.task_status='WKS' then '未开始'
                     when a.task_status='JXZ' then '进行中'
                     when a.task_status='YWC' then '已完成'
                     when a.task_status='YQWWC' then '逾期未完成'
                 end as task_finish,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
			from
             tm_task_info a
             left join pm_college_plan_info b on
             a.plan_no=b.plan_no
             where b.plan_layer='G_COURSE' and b.status='NORMAL'
             and a.task_delete='NORMAL'
             and a.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'
             and b.start_date BETWEEN '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 课程体规划任务情况：${HIVE_DB}.${HIVE_TABLE}"
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
         import_table_report_no
    fi
    done

}

RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
plan_getYearData
finish

#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_college_quality_report_plan
HIVE_DB=assurance
TARGET_TABLE=qu_college_quality_report_plan

#学院层面规划完成情况
#sh -x $0
function import_table_report_no() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         set names utf8;
         INSERT INTO ${TARGET_TABLE}(report_no,plan_name,plan_no,child_plan_name,
            manager_name,plan_finish,task_finish,create_time)
               select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                XYCMYWCGH.plan_name,
                XYCMYWCGH.plan_no,
                XYCMYWCGH.child_plan_name,
                XYCMYWCGH.manager_name,
                XYCMYWCGH.plan_finish,
                case when XYCMSYGH.num=0 then 0 else concat(cast(XYCMYWCGH.task_finish / XYCMSYGH.num*100 as DECIMAL(9,2)),'','%') end  as task_finish,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                from
                (
                select
                a.plan_name as plan_name,
                a.plan_no as plan_no,
                b.plan_name as child_plan_name,
                b.manager_name as manager_name,
                case when b.plan_status='DSH' then '待审核'
                     when b.plan_status='SHZ' then '审核中'
                     when b.plan_status='SHWTG' then '审核未通过'
                     when b.plan_status='WKS' then '未开始'
                     when b.plan_status='JXZ' then '进行中'
                     when b.plan_status='YWC' then '已完成'
                     when b.plan_status='YQWWC' then '逾期未完成'
                     end as plan_finish ,
                sum(case when c.task_status ='YWC' then 1 else 0 end) as task_finish
                from
                pm_college_plan_info a
                left join
                pm_college_plan_info b
                on a.plan_no=b.relation_plan_no
                left join
                tm_task_info c on
                b.plan_no=c.plan_no
                where a.relation_plan_no is null or a.relation_plan_no='' and a.status='NORMAL'
				and a.plan_layer='G_COLLEGE' and c.task_delete='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
				group by a.plan_no,a.plan_name,b.plan_name,b.manager_name,b.plan_status
				) XYCMYWCGH
				left join
				(
                select b.plan_name,b.manager_name,count(c.task_no) as num
                from pm_college_plan_info a left join
                pm_college_plan_info b on a.plan_no=b.relation_plan_no
                left join tm_task_info c on b.plan_no=c.plan_no
                where a.relation_plan_no is null or a.relation_plan_no='' and a.status='NORMAL' and c.task_delete='NORMAL'
				and a.plan_layer='G_COLLEGE' and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
				group by b.plan_name,b.manager_name
                ) XYCMSYGH
                 on XYCMYWCGH.child_plan_name=XYCMSYGH.plan_name and XYCMYWCGH.manager_name=XYCMSYGH.manager_name
            "
    fn_log "导入数据 —— 学院层面规划完成情况：${HIVE_DB}.${TARGET_TABLE}"
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

#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_college_quality_report_quality
HIVE_DB=assurance
TARGET_TABLE=qu_college_quality_report_quality
### 学院层面质控点信息
### 乱码情况：set names utf8;
### sh -x $0
function import_table_report_no() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    find_mysql_data "
         set names utf8;
         INSERT INTO ${TARGET_TABLE}(report_no,index_no,index_name,quality_name,standard_val,
         target_val,current_val,is_standard,create_time)
              select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COLLEGE')  as report_no,
                tmp.index_no,
                tmp.index_name,
                tmp.quality_name,
                case when tmp2.num=0 then 0
                else concat(cast(tmp.standard_val/tmp2.num *100 as decimal(9,2)),'','%') end as standard_val,
                case when tmp2.num=0 then 0
                else concat(cast(tmp.target_val/tmp2.num *100 as decimal(9,2)),'','%') end as target_val,
                tmp.current_val,
				case tmp.is_standard when 'YES' then '达标' else '未达标' end as is_standard ,
				FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                from
                (select
                a.index_no,a.index_name,b.quality_name,b.standard_val,
                b.target_val,b.current_val,b.is_standard
                from im_index_info a
                left join
                (
                    select
                    im.second_index_no,
                    im.quality_name,
                    count(case when ic.is_standard = 'YES' then im.quality_no end) as standard_val,
                    count(case when ic.is_target = 'YES' then im.quality_no end)  as target_val,
                    0 as current_val,
                    ic.is_standard
                    from
                    im_quality_info im
                    left join
                    im_college_target_standard_record ic
                    on im.quality_no=ic.quality_no
                    where im.quality_status='NORMAL'
                    and im.index_layer='COLLEGE'
                    and ic.semester_year='${SEMESTER_YEARS}'
                    and substr(im.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
                    group by im.second_index_no,
                    im.quality_name,
                    ic.is_standard
                ) b
                on a.index_no=b.second_index_no
                where a.index_layer='COLLEGE' and a.index_level='SECOND'
                and a.index_status='NORMAL'
                and substr(a.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
                ) tmp
                left join
                (
                select a.index_no,count(0) as num from im_index_info a
                left join (select im.second_index_no from
                im_quality_info im left join
                im_college_target_standard_record ic
                on im.quality_no=ic.quality_no
                where im.quality_status='NORMAL'
                and im.index_layer='COLLEGE'
                and ic.semester_year='${SEMESTER_YEARS}'
                and substr(im.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
				)b
				on a.index_no=b.second_index_no
				where a.index_layer='COLLEGE' and a.index_level='SECOND'
                and a.index_status='NORMAL'
                and substr(a.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
                group by a.index_no
                )tmp2
                on tmp.index_no=tmp2.index_no
            "
    fn_log "导入数据 —— 学院层面质控点信息：${HIVE_DB}.${TARGET_TABLE}"
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


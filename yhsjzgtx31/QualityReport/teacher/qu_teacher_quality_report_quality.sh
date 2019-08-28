#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_teacher_quality_report_quality
#教师层面质控点信息
HIVE_DB=assurance
TARGET_TABLE=qu_teacher_quality_report_quality
# report_no String comment '报告编号',
# index_no  String comment '二级指标编号',
# index_name String comment '二级指标名称',
# quality_name String comment '质控点名称',
# standard_rate String comment '标准达标率',
# target_rate String comment '目标达标率',
# teacher_num String comment '质控点适用教师人数',
# quality_reason String COMMENT '原因分析（暂时为空）',
# quality_action String  COMMENT '改进措施（暂时为空）',
# quality_effect String  COMMENT '改进成效（暂时为空）',
# create_time String comment '创建时间'

function import_table_report_no() {
clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
        set names utf8;
         INSERT INTO  ${TARGET_TABLE}(
         report_no,index_no,index_name,quality_name,standard_rate,target_rate,teacher_num,create_time
         )
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','TEACHER') as report_no,
                tmp.index_no,
                tmp.index_name,
                tmp.quality_name,
                case when tmp2.num=0 then 0
                else cast(tmp.standard_val/tmp2.num *100 as decimal(9,2)) end as standard_rate,
                case when tmp2.num=0 then 0
                else cast(tmp.target_val/tmp2.num *100 as decimal(9,2)) end as target_rate,
                tmp.teacher_num as  teacher_num,
				FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                from
                (select
                a.index_no,a.index_name,b.quality_name,b.standard_val,
                b.target_val,b.teacher_num
                from im_index_info a
                left join
                (
                    select
                    im.second_index_no,
                    im.quality_name,
                    count(case when ic.is_standard = 'YES' then im.quality_no end) as standard_val,
                    count(case when ic.is_target = 'YES' then im.quality_no end)  as target_val,
                    count(ic.teacher_no) as teacher_num
                    from
                    im_quality_info im
                    left join
                    im_teacher_target_standard_record ic
                    on im.quality_no=ic.quality_no
                    where im.quality_status='NORMAL'
                    and im.index_layer='TEACHER'
                    and substr(im.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
                    and ic.semester_year='${SEMESTER_YEARS}'
                    group by im.second_index_no,
                    im.quality_name
                ) b
                on a.index_no=b.second_index_no
                where a.index_layer='TEACHER' and a.index_level='SECOND'
                and a.index_status='NORMAL'
                and substr(a.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
                ) tmp
                left join
                (
                select a.index_no,count(0) as num from im_index_info a
                left join (select im.second_index_no from
                im_quality_info im left join
                im_teacher_target_standard_record ic
                on im.quality_no=ic.quality_no
                where im.quality_status='NORMAL'
                and im.index_layer='TEACHER'
                and ic.semester_year='${SEMESTER_YEARS}'
                and substr(im.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
				)b
				on a.index_no=b.second_index_no
				where a.index_layer='TEACHER' and a.index_level='SECOND'
                and a.index_status='NORMAL'
                and substr(a.create_time,1,10) between '${BEGIN_TIME}' and '${END_TIME}'
                group by a.index_no
                )tmp2
                on tmp.index_no=tmp2.index_no
            "
    fn_log "导入数据 —— 教师层面质控点信息 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



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


plan_getYearData
finish

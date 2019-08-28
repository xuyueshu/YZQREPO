#!/bin/sh
cd `dirname $0`
source ./config.sh
exec_dir mission_early_warning_proportion

TARGET_TABLE=ef_assess_point_data_value_info
#DATA_NAME=任务预警占比
DATA_NO=RWYJZB


function import_table() {
    find_mysql_data "
        set names utf8;
        INSERT INTO ${TARGET_TABLE}
        (data_no,data_name,first_index_type,data_cycle,data_type,data_time,data_value,is_new,create_time)
        select
        b.data_no as data_no,
        b.data_name as data_name,
        b.first_index_type as first_index_type,
        b.data_cycle as data_cycle,
        b.data_type as data_type,
        a.start_date  data_time,
        cast(a.num2/a.num1*100 as decimal(9,2)) as data_value,
        'NO' as is_new,
        FROM_UNIXTIME(UNIX_TIMESTAMP()) as create_time
        from
          (select
           a.start_date,
           count(a.task_no) as num1,
		   count(c.task_no) as num2
           from
           tm_task_info a
		   left join
           pm_college_plan_info b
           on a.plan_no=b.plan_no
           left join
           tm_task_warn_info c
           on a.task_no=c.task_no and a.start_date=c.task_warn
		   where b.plan_layer='G_TEACHER'
           and b.status='NORMAL'
           and a.task_delete='NORMAL'
		   and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
		  GROUP BY a.start_date
		  ) a,
          base_assess_point_data_info b
          where b.data_no='${DATA_NO}'
    "
       fn_log "创建表——任务预警占比：${TARGET_TABLE}"
}

#查找${TARGET_TABLE}表中时间最近的数据，${TARGET_TABLE}表的is_new的NO改成YES
function export_table() {
     #删除库中最新数据
     clear_mysql_data "delete from ${TARGET_TABLE} where DATA_NO='${DATA_NO}' and data_time between '${BEGIN_TIME}' and '${END_TIME}'"
     #导入最新数据
     import_table
     #查找最新的数据
     DATE_TIME=`find_mysql_data "select max(data_time) from ${TARGET_TABLE} where data_no='${DATA_NO}' ;" `
     #以后的每一次执行都会修改这个is_new字段，所以全部改成NO
     clear_mysql_data "update ${TARGET_TABLE} set is_new = 'NO' where data_no='${DATA_NO}';"
     #is_new的NO改成YES
     clear_mysql_data "update ${TARGET_TABLE} set is_new = 'YES' where data_time='${DATE_TIME}' and data_no='${DATA_NO}';"
}


#base_assess_point_data_info 判断质控点'${DATA_NO}'是不是开启
function alter_table(){
is_open=`find_mysql_data "select data_status from base_assess_point_data_info where data_no ='${DATA_NO}';" `
if [  $is_open == "OPEN"  ]
then
        echo " 质控点开启 "
        #第一次导入
        export_table
        #script_status的NO改成YES
        clear_mysql_data "update base_assess_point_data_info set script_status= 'YES' where data_no='${DATA_NO}';"
else
        echo "质控点没有开启 "

fi
}

#抽取begin_time/end_time之间的数据，根据第一学期和第二学期进行数据抽取
function JX_getYearData() {
    find_mysql_data "
    select date_format(DATE_FORMAT(begin_time,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') as begin_time,
	 date_format(DATE_FORMAT(end_time,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') as end_time
	 from base_school_calendar_info where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;"| while read -a row
    do
      BEGIN_TIME=${row[0]}
      END_TIME=${row[1]}
      if [ ! -n "$BEGIN_TIME" ]; then
         echo "SEMESTER_YEAR IS NULL!"
      else
         echo "SEMESTER_YEAR IS NOT NULL"
         echo ${BEGIN_TIME}"=="${END_TIME}
         alter_table
    fi
    done

}

JX_getYearData
finish














#!/bin/sh
cd `dirname $0`
source ./config.sh
exec_dir student_attendance_rate

TARGET_TABLE=ef_assess_point_data_value_info
#DATA_NAME=学生到课率
DATA_NO=XXDKL

function import_table() {
find_mysql_data "
        set names utf8;
        INSERT INTO ${TARGET_TABLE}(data_no,data_name,first_index_type,data_cycle,data_type,data_time,data_value,is_new,create_time)
        select
        b.data_no as data_no,
        b.data_name as data_name,
        b.first_index_type as first_index_type,
        b.data_cycle as data_cycle,
        b.data_type as data_type,
        a.data_time as data_time,
        cast(avg(a.data_value) as DECIMAL(9,1)) as data_value,
        'NO' as is_new,
        FROM_UNIXTIME(UNIX_TIMESTAMP()) as create_time
        from
        im_quality_teacher_data_info a ,base_assess_point_data_info b
        where b.data_no='${DATA_NO}' and a.data_no = 'SZ_XSDKL'
        group by b.data_no,b.data_name,b.first_index_type,b.data_cycle,b.data_type,a.data_time

            "
    fn_log "导出数据 —— 学生到课率表：${HIVE_DB}.${HIVE_TABLE}"
}

#第一次导入数据
function export_table() {
     #删除库中数据
     clear_mysql_data "delete from ${TARGET_TABLE} where data_no='${DATA_NO}';"
     #导入数据
     import_table
     #查找库中里面最新的数据
     DATE_TIME=`find_mysql_data "select max(data_time) from ${TARGET_TABLE} where data_no='${DATA_NO}';" `
      #以后的每一次执行都会修改这个is_new字段，所以全部改成NO
     clear_mysql_data "update ${TARGET_TABLE} set is_new = 'NO' where data_no='${DATA_NO}';"
     #is_new的NO改成YES
     clear_mysql_data "update ${TARGET_TABLE} set is_new = 'YES' where data_time='${DATE_TIME}' and data_no='${DATA_NO}';"
}

function import_table_new() {
find_mysql_data "
        set names utf8;
        INSERT INTO ${TARGET_TABLE}(data_no,data_name,first_index_type,data_cycle,data_type,data_time,data_value,is_new,create_time)
        select
        b.data_no as data_no,
        b.data_name as data_name,
        b.first_index_type as first_index_type,
        b.data_cycle as data_cycle,
        b.data_type as data_type,
        a.data_time as data_time,
        cast(avg(a.data_value) as DECIMAL(9,1)) as data_value,
        'NO' as is_new,
        FROM_UNIXTIME(UNIX_TIMESTAMP()) as create_time
        from
        im_quality_teacher_data_info a ,base_assess_point_data_info b
        where b.data_no='${DATA_NO}' and a.data_no = 'SZ_XSDKL'
        and a.data_time=concat('${SEMESTER_YEARS}','-','${SEMESTERS}')
        group by b.data_no,b.data_name,b.first_index_type,b.data_cycle,b.data_type,a.data_time

            "
    fn_log "导出数据 —— 学生到课率表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table_new() {
     #删除库中数据
     clear_mysql_data "delete from ${TARGET_TABLE} where data_time=concat('${SEMESTER_YEARS}','-','${SEMESTERS}') and data_no='${DATA_NO}';"
     #导入最新数据
     import_table_new
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
         export_table
         export_table_new
         #script_status的NO改成YES
         clear_mysql_data "update base_assess_point_data_info set script_status= 'YES' where data_no='${DATA_NO}';"
else
        echo "质控点没有开启 "

fi
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
        alter_table
    fi

}

select_semester_year
finish
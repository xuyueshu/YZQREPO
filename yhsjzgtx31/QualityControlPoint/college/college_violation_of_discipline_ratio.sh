#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir college_violation_of_discipline_ratio

HIVE_DB=assurance
HIVE_TABLE=college_violation_of_discipline_ratio
TARGET_TABLE=im_quality_data_info
#DATA_NAME=违纪比例
DATA_NO=XY_WJBL

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                 data_no String comment '数据项编号',
                data_name String comment '数据项名称',
                data_cycle String comment '数据统计周期  YEAR 年  MONTH 月  DAY 日  QUARTER 季度 OTHER 其他',
                data_type String comment '数据类型（NUMBER或者ENUM）',
                data_time String comment '数据日期  年YYYY  月YYYYmm 日YYYYMMDD  季度YYYY-1，yyyy-2,yyyy-3,yyyy-4   学期 yyyy-yyyy  学期 yyyy-yyyy-1,yyyy-yyyy-2',
                data_value String comment '数据项值（数字保存数字，如果是数据字典枚举保存key）',
                is_new String comment '是否最新 是YES 否NO',
                create_time String comment '创建时间'
    ) COMMENT '学校省级以上获奖数量表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学校省级以上获奖数量表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                c.data_no as data_no,
                c.data_name as data_name,
                c.data_cycle as data_cycle,
                c.data_type as data_type,
                a.semester_year as data_time,
                a.count_w as data_value,
                 'NO' as is_new,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                   select
                    CONCAT(cast(sum(a.night_out_num+a.health_disqualification_num)/sum(b.student_num)*100 as decimal(9,2)),'','%') as count_w,
                     a.semester_year from
                   app.student_behavior_count a
                   left join
                   app.college_enrolment_method_count b
                   on a.semester_year=b.semester_year
                    group by a.semester_year
                   )a,
                   assurance.im_quality_data_base_info c
                where c.data_no = '${DATA_NO}'
            "
    fn_log "导入数据 —— 学校省级以上获奖数量表：${HIVE_DB}.${HIVE_TABLE}"
}
#插入新数据
function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                 select
                c.data_no as data_no,
                c.data_name as data_name,
                c.data_cycle as data_cycle,
                c.data_type as data_type,
                a.semester_year as data_time,
                a.count_w as data_value,
                 'NO' as is_new,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                   (
                   select
                    CONCAT(cast(sum(a.night_out_num+a.health_disqualification_num)/sum(b.student_num)*100 as decimal(9,2)),'','%') as count_w,
                     a.semester_year from
                   app.student_behavior_count a
                   left join
                   app.college_enrolment_method_count b
                   on a.semester_year=b.semester_year
                    group by a.semester_year
                   )a,
                   assurance.im_quality_data_base_info c
                   where c.data_no = '${DATA_NO}'
                   order by data_time desc
                   limit 1
         "
}
function export_table() {
    clear_mysql_data "delete from im_quality_data_info where data_no = '${DATA_NO}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'YES' where data_no = '${DATA_NO}' order by substr(data_time,1,4) desc limit 1;"

    fn_log "导出数据--学校质控点数据项信息表:${HIVE_DB}.${TARGET_TABLE}"
}
function export_table_new(){
  DATE_TIME=`hive -e "select data_time from ${HIVE_DB}.${HIVE_TABLE}"`
    clear_mysql_data "
                delete from
                  im_quality_data_info
                where
                  data_no = '${DATA_NO}'
                  and data_time = '${DATE_TIME}';
                "

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'YES' where data_no = '${DATA_NO}' order by substr(data_time,1,4) desc limit 1;"

}

##第一次执行
##执行create_table，import_table，export_table，
#create_table
#import_table
#export_table
##以后的每次执行
##执行import_table_new，export_table_new
##import_table_new
##export_table_new
#finish
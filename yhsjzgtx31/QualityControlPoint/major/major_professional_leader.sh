#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir major_professional_leader

HIVE_DB=assurance
HIVE_TABLE=major_professional_leader
TARGET_TABLE=im_quality_major_data_info
DATA_NAME=有无专业带头人
DATA_NO=ZY_YWZYDTR

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                 data_no  String comment '数据项编号',
                 data_name  String comment '数据项名称',
                 major_no  String comment '专业编号',
                 major_name String comment '专业名称',
                 data_cycle String comment '数据统计周期  YEAR 年  MONTH 月  DAY 日  QUARTER 季度 OTHER 其他',
                 data_type String comment '数据类型  NUMBER 数值类型  ENUM 枚举类型',
                 data_time String comment '数据日期  年YYYY  月YYYYmm 日YYYYMMDD  季度YYYY-1，yyyy-2,yyyy-3,yyyy-4   学期 yyyy-yyyy  学期 yyyy-yyyy-1,yyyy-yyyy-2',
                 data_value String comment '数据项值（数字保存数字，如果是数据字典枚举保存key）',
                 is_new String comment '是否最新 是YES 否NO',
                 create_time String comment '创建时间'
    ) COMMENT '有无专业带头人'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——有无专业带头人：${HIVE_DB}.${HIVE_TABLE}"
}
function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                   c.data_no as data_no,
                   c.data_name as data_name,
                   a.major_code as major_no,
                   a.major_name as major_name,
                   c.data_cycle as data_cycle,
                   c.data_type as data_type,
                   a.semester_year as  data_time,
                   case when a.num >0 then '有' else '无' end  as data_value,
                   'NO' as is_new,
                   FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
               from
                 (
                     select
                     count(case when is_major_leader ='1' then code end) as num,
                     major_code,
                     major_name,
                     semester_year
                     from
                     model.basic_teacher_info
                     where is_quit='2' and major_code is not null
                     group by major_code,major_name,semester_year
                 )a,
                 assurance.im_quality_data_base_info c
                 where c.data_no ='${DATA_NO}'
            "
    fn_log "导入数据 —— 有无专业带头人：${HIVE_DB}.${HIVE_TABLE}"
}
#插入新数据
function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                   c.data_no as data_no,
                   c.data_name as data_name,
                   a.major_code as major_no,
                   a.major_name as major_name,
                   c.data_cycle as data_cycle,
                   c.data_type as data_type,
                   a.semester_year as  data_time,
                   case when a.num >0 then '有' else '无' end  as data_value,
                   'NO' as is_new,
                   FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
               from
                 (
                     select
                     count(case when s.is_major_leader ='1' then s.code end) as num,
                     s.major_code,
                     s.major_name,
                     s.semester_year
                     from
                     model.basic_teacher_info s
                     where s.is_quit='0'
                     and  s.semester_year in
                    (select max(s.semester_year) from model.basic_teacher_info s )
                     group by s.major_code,s.major_name,s.semester_year
                 )a,
                 assurance.im_quality_data_base_info c
                 where c.data_no ='${DATA_NO}'
         "
          fn_log "导入数据 —— 有无专业带头人：${HIVE_DB}.${HIVE_TABLE}"
}
#第一次执行
function export_table() {
    DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_major_data_info where data_no = '${DATA_NO}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,major_no,major_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

   clear_mysql_data "update assurance.im_quality_major_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
    clear_mysql_data "update assurance.im_quality_major_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time='${DATE_TIME}'"
    fn_log "导出数据--有无专业带头人:${HIVE_DB}.${TARGET_TABLE}"
}

#导入新数据
function export_table_new() {
     DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_major_data_info
            where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,major_no,major_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_major_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
     clear_mysql_data "update assurance.im_quality_major_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}' "
    fn_log "导出数据--有无专业带头人:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
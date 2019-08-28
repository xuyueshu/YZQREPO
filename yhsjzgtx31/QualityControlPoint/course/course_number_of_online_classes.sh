#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir course_number_of_online_classes

HIVE_DB=assurance
HIVE_TABLE=course_number_of_online_classes
TARGET_TABLE=im_quality_course_data_info
DATA_NAME=在线课堂数量

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                data_no String comment '数据项编号',
                data_name String comment '数据项名称',
                 course_name String comment '课程名称',
                course_code String comment '课程代码',
                data_cycle String comment '数据统计周期  YEAR 年  MONTH 月  DAY 日  QUARTER 季度 OTHER 其他',
                data_type String comment '数据类型（NUMBER或者ENUM）',
                data_time String comment '数据日期  年YYYY  月YYYYmm 日YYYYMMDD  季度YYYY-1，yyyy-2,yyyy-3,yyyy-4   学期 yyyy-yyyy  学期 yyyy-yyyy-1,yyyy-yyyy-2',
                data_value String comment '数据项值（数字保存数字，如果是数据字典枚举保存key）',
                is_new String comment '是否最新 是YES 否NO',
                create_time String comment '创建时间'
    ) COMMENT '在线课堂数量'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——在线课堂数量：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select distinct
                c.data_no as data_no,
                c.data_name as data_name,
                a.course_name as course_name,
                a.course_code as course_code,
                c.data_cycle as data_cycle,
                c.data_type as data_type,
                concat(a.semester_year,'-',a.semester) as data_time,
                a.c as data_value,
                  'NO' as is_new,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (select a.semester_year,a.semester,a.course_code,a.course_name,sum(a.online_num) as c from model.course_resource a
                where a.online_num=1
                group by a.semester_year,a.semester,a.course_code,a.course_name
                ) a,
                assurance.im_quality_data_base_info c
                where c.data_name = '${DATA_NAME}'
            "
    fn_log "导入数据 —— 在线课堂数量：${HIVE_DB}.${HIVE_TABLE}"
}
#插入新数据
function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                    select
                        c.data_no as data_no,
                        c.data_name as data_name,
                        a.course_name as course_name,
                        a.course_code as course_code,
                        c.data_cycle as data_cycle,
                        c.data_type as data_type,
                        concat(a.semester_year,'-',a.semester) as data_time,
                        a.c as data_value,
                         'NO' as is_new,
                        FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                    from
                      (
                      select a.semester_year,a.semester,a.course_code,a.course_name,sum(a.online_num) as c from model.course_resource a
                      where a.online_num=1 and  a.semester_year in (select max(semester_year) from model.course_resource)
                      group by a.semester_year,a.course_code,a.course_name,a.semester
                      ) a,
                      assurance.im_quality_data_base_info c
                      where c.data_name = '${DATA_NAME}'
         "
}
function export_table() {
     DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_course_data_info where data_name = '${DATA_NAME}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,course_name,course_code,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_course_data_info set is_new = 'NO' where data_name = '${DATA_NAME}';"
     clear_mysql_data "update assurance.im_quality_course_data_info set is_new = 'YES' where data_name = '${DATA_NAME}' and data_time='${DATE_TIME}';"
    fn_log "导出数据--学校质控点数据项信息表:${HIVE_DB}.${TARGET_TABLE}"
}
function export_table_new(){
  DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "
                delete from
                  im_quality_course_data_info
                where
                  data_name = '${DATA_NAME}'
                  and data_time = '${DATE_TIME}';
                "

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,course_name,course_code,data_cycle,data_type,data_time,data_value,is_new,create_time'

    clear_mysql_data "update assurance.im_quality_course_data_info set is_new = 'NO' where data_name = '${DATA_NAME}';"
    clear_mysql_data "update assurance.im_quality_course_data_info set is_new = 'YES' where data_name = '${DATA_NAME}' and data_time='${DATE_TIME}';"
    fn_log "导出数据--学校质控点数据项信息表:${HIVE_DB}.${TARGET_TABLE}"
 }


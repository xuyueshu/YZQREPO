#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir college_student_instructor_ratio

HIVE_DB=assurance
HIVE_TABLE=college_student_instructor_ratio
TARGET_TABLE=im_quality_data_info
DATA_NO=XY_FDYSSB

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
    ) COMMENT '辅导员生师比'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            SELECT
              e.data_no as data_no,
              e.data_name as data_name,
              e.data_cycle as data_cycle,
              e.data_type as data_type,
              concat(d.semester_year,'-',d.semester) as data_time,
              cast((d.num / b.num) as DECIMAL(6,2)) as data_value,
              'NO' as is_new,
              FROM_UNIXTIME(
                UNIX_TIMESTAMP()
              ) AS create_time
            FROM
            (
                SELECT
                          count(b.code) as num,
                          b.semester_year as semester_year,
                          b.semester
                        from
                          app.basic_semester_student_info b
                        group by
                          b.semester_year,b.semester
              ) d
              left join
              (
                SELECT
                  count(a.code) as num,
                  grade
                FROM
                  model.basic_instructor_info a
                  group by grade
              ) b
              on substr(d.semester_year,6,4)=b.grade
              ,assurance.im_quality_data_base_info e
              where e.data_no = '${DATA_NO}'

         "
}

function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            SELECT
              e.data_no as data_no,
              e.data_name as data_name,
              e.data_cycle as data_cycle,
              e.data_type as data_type,
              concat(d.semester_year,'-',d.semester) as data_time,
              cast((d.num / b.num) as DECIMAL(6,2)) as data_value,
              'NO' as is_new,
              FROM_UNIXTIME(
                UNIX_TIMESTAMP()
              ) AS create_time
            FROM
            (
                SELECT
                          count(b.code) as num,
                          b.semester_year as semester_year,
                          b.semester
                        from
                          app.basic_semester_student_info b
                        group by
                          b.semester_year,b.semester
              ) d
              left join
              (
                SELECT
                  count(a.code) as num,
                  grade
                FROM
                  model.basic_instructor_info a
                  group by grade
              ) b
              on substr(d.semester_year,6,4)=b.grade
              ,assurance.im_quality_data_base_info e
              where e.data_no = '${DATA_NO}'
              order by
                  data_time desc
                limit
                  1
         "
}

function export_table() {
    DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE}"`
    clear_mysql_data "
                delete from
                  im_quality_data_info
                where
                 data_no = '${DATA_NO}'
                  ;
                "

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time='${DATE_TIME}'"
}



function export_table_new(){
  DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE}"`
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
    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time='${DATE_TIME}'"
}




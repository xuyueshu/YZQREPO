#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir college_teacher_sex_num

HIVE_DB=assurance
HIVE_TABLE=college_teacher_sex_num
TARGET_TABLE=im_quality_data_info
DATA_NO=XY_JZGRYXBBL

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
    ) COMMENT '教职工人员性别比例'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
         select
          f.data_no as data_no,
          f.data_name as data_name,
          f.data_cycle as data_cycle,
          f.data_type as data_type,
          e.data_time as data_time,
          e.data_value as data_value,
          'NO' as is_new,
          FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
         from
         (
            select
              concat(c.num,':',d.num) as data_value,
              c.time as data_time
            from
              (
                select
                  count(a.code) as num,
                  a.semester_year as time
                from
                  model.basic_teacher_info a
                where
                  a.sex = '1'
                group by a.semester_year
              ) c
              left join
              (
                select
                  count(a.code) as num,
                  a.semester_year as time
                from
                  model.basic_teacher_info a
                where
                  a.sex = '2'
                group by a.semester_year
              ) d
            where c.time = d.time
         ) e,assurance.im_quality_data_base_info f
              where f.data_no = '${DATA_NO}'

            "
}

function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                select
                  f.data_no as data_no,
                  f.data_name as data_name,
                  f.data_cycle as data_cycle,
                  f.data_type as data_type,
                  e.data_time as data_time,
                  e.data_value as data_value,
                  'NO' as is_new,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                from
                  (
                    select
                      cast(
                        c.num / d.num as decimal(5, 2)
                      ) as data_value,
                      c.time as data_time
                    from
                      (
                        select
                          count(a.code) as num,
                          a.semester_year as time
                        from
                          model.basic_teacher_info a
                        where
                          a.sex = '1'
                        group by
                          a.semester_year
                      ) c
                      left join
                      (
                        select
                          count(a.code) as num,
                          a.semester_year as time
                        from
                          model.basic_teacher_info a
                        where
                          a.sex = '2'
                        group by
                          a.semester_year
                      ) d
                    where
                      c.time = d.time
                  ) e,
                  assurance.im_quality_data_base_info f
                where
                  f.data_no = '${DATA_NO}'
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


#create_table
#import_table
#export_table
#create_table
#import_table_new
#export_table_new
#finish
#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir college_quality_engineering_num

HIVE_DB=assurance
HIVE_TABLE=college_quality_engineering_num
TARGET_TABLE=im_quality_data_info
DATA_NO=XY_ZLGCSL

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
    ) COMMENT '质量工程数量'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                  c.data_no as data_no,
                  c.data_name as data_name,
                  c.data_cycle as data_cycle,
                  c.data_type as data_type,
                  a.semester_year as data_time,
                  a.count_p as data_value,
                  'NO' as is_new,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                FROM
                 (
                     select
                     cast(sum(a.first_class_professional+
                             a.backbone_professional+
                                     a.major_teach_resource+
                                          a.online_course_count+
                                              a.innovation_department+
                                                          a.teach_awrad) as int) as count_p,
                     a.semester_year
                     from model.college_quality_info a
                     group by  a.semester_year
                 ) a,
                 assurance.im_quality_data_base_info c
                where c.data_no = '${DATA_NO}'
         "
}

function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                  c.data_no as data_no,
                  c.data_name as data_name,
                  c.data_cycle as data_cycle,
                  c.data_type as data_type,
                  a.semester_year as data_time,
                  a.count_p as data_value,
                  'NO' as is_new,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                FROM
                  (select
                     cast(sum(a.first_class_professional+
                             a.backbone_professional+
                                     a.major_teach_resource+
                                          a.online_course_count+
                                              a.innovation_department+
                                                          a.teach_awrad) as int) as count_p,
                     a.semester_year
                     from model.college_quality_info a
                     where a.semester_year in (select max(semester_year) from model.college_quality_info)
                     group by  a.semester_year
                 )a,
                  assurance.im_quality_data_base_info c
                where
                  c.data_no = '${DATA_NO}'

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

function find_mysql_data() {
	mysql -h ${MYSQL_HOST} -u ${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -P${MYSQL_PORT} -N -e "USE ${MYSQL_DB};${1}"
}
function run_Script(){
 DATA_STATUS=`find_mysql_data "select data_status from assurance.im_quality_data_base_info where where data_no = '${DATA_NO}';"`
    if [  $DATA_STATUS == "OPEN"  ]
        then
        create_table
        import_table
        export_table

    fi
}
#run_Script
##第一次执行
##执行create_table，import_table，export_table，
##create_table
##import_table
##export_table
##以后的每次执行
##执行import_table_new，export_table_new
##import_table_new
##export_table_new
#finish


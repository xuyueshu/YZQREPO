#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir college_excellent_resources_sharing_course

#无数据支持
HIVE_DB=assurance
HIVE_TABLE=college_excellent_resources_sharing_course
TARGET_TABLE=im_quality_data_info
DATA_NAME=精品资源共享课数量

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                 data_no String comment '数据项编号',
                 data_name String comment '数据项名称',
                 data_cycle String comment '数据统计周期  YEAR 年  MONTH 月  DAY 日  QUARTER 季度 OTHER 其他',
                 data_type String comment '数字 NUMBER 枚举ENUM',
                 data_time String comment '数据日期',
                 data_value String comment '数据项值（数字保存数字，如果是数据字典枚举保存key）',
                 is_new String comment '是否最新 是YES 否NO',
                 create_time String comment '创建时间'
    ) COMMENT '学校精品资源共享课数量表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学校精品资源共享课数量表：${HIVE_DB}.${HIVE_TABLE}"
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
                a.course_num as data_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               (select count(1) as course_number,a.semester_year from model.course_achievement_record a where category = 3 and sub_category = 2 group by semester_year) a,assurance.im_quality_data_base_info c
                where c.data_name = '${DATA_NAME}'
            "
    fn_log "导入数据 —— 学校精品资源共享课数量表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "delete from im_quality_data_info where data_name = ${DATA_NAME};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,data_cycle,data_type,data_time,data_value,create_time'

    fn_log "导出数据--学校质控点数据项信息表:${HIVE_DB}.${TARGET_TABLE}"
}


create_table
import_table
export_table
finish


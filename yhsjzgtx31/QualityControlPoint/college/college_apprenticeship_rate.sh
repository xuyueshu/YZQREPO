#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir college_apprenticeship_rate

HIVE_DB=assurance
HIVE_TABLE=college_apprenticeship_rate
TARGET_TABLE=im_quality_data_info
DATA_NO=XY_HZQYXTZPYRSZQRZGZZXSRSBL

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
    ) COMMENT '合作企业学徒制培养人数占全日制高职在校生人数比例'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——合作企业学徒制培养人数占全日制高职在校生人数比例：${HIVE_DB}.${HIVE_TABLE}"
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
                      concat(cast(a.n/b.s * 100 as decimal(9,2)),'','%') as data_value,
                      'NO' as is_new,
                      FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                    from
                    (
                        select
                        sum(a.student_count) as n,
                        a.semester_year
                        from
                        app.major_plan_student a
                        where a.type=2
                        group by semester_year
                    )a
                    left join
                    (
                        select
                        count(1) as s,
                        b.semester_year
                        from
                        model.basic_student_info a,
                        app.basic_semester_student_info b
                        where status = 1 and in_school = 1
                        and a.code = b.code
                        group by b.semester_year
                    ) b
                   on a.semester_year = b.semester_year,
                   assurance.im_quality_data_base_info c
                   where c.data_no = '${DATA_NO}'
            "
    fn_log "导入数据 —— 合作企业学徒制培养人数占全日制高职在校生人数比例：${HIVE_DB}.${HIVE_TABLE}"
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
                      concat(cast(a.n/b.s * 100 as decimal(9,2)),'','%') as data_value,
                      'NO' as is_new,
                      FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
                    from
                    (
                        select
                        sum(a.student_count) as n,
                        a.semester_year
                        from
                        app.major_plan_student a
                        group by semester_year
                    )a
                    left join
                    (
                        select
                        count(1) as s,
                        b.semester_year
                        from
                        model.basic_student_info a,
                        app.basic_semester_student_info b
                        where status = 1 and in_school = 1
                        and a.code = b.code
                        group by b.semester_year
                    ) b
                   on a.semester_year = b.semester_year,
                   assurance.im_quality_data_base_info c
                   where c.data_no = '${DATA_NO}' order by data_time desc limit 1
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

    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'NO' where data_name = '${DATA_NAME}';"
    clear_mysql_data "update assurance.im_quality_data_info set is_new = 'YES' where data_name = '${DATA_NAME}' and data_time='${DATE_TIME}'"
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

create_table
import_table
export_table
#以后的每次执行
#执行import_table_new，export_table_new
create_table
import_table_new
export_table_new
finish
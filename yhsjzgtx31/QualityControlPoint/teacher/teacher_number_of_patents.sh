#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir teacher_number_of_patents

HIVE_DB=assurance
HIVE_TABLE=teacher_number_of_patents
TARGET_TABLE=im_quality_teacher_data_info
DATA_NO=SZ_ZLSL

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                data_no  String comment '数据项编号',
                 data_name  String comment '数据项名称',
                 teacher_name  String comment '教师姓名',
                 teacher_no String comment '教师编号',
                 data_cycle String comment '数据统计周期  YEAR 年  MONTH 月  DAY 日  QUARTER 季度 OTHER 其他',
                 data_type String comment '数据类型  NUMBER 数值类型  ENUM 枚举类型',
                 data_time String comment '数据日期  年YYYY  月YYYYmm 日YYYYMMDD  季度YYYY-1，yyyy-2,yyyy-3,yyyy-4   学期 yyyy-yyyy  学期 yyyy-yyyy-1,yyyy-yyyy-2',
                 data_value String comment '数据项值（数字保存数字，如果是数据字典枚举保存key）',
                  is_new String comment '是否最新 是YES 否NO',
                 create_time String comment '创建时间'
    ) COMMENT '专利数量'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——专利数量：${HIVE_DB}.${HIVE_TABLE}"
}


function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                   c.data_no as data_no,
                   c.data_name as data_name,
                   a.teacher_name as teacher_name,
                   a.teacher_no as teacher_no,
                   c.data_cycle as data_cycle,
                   c.data_type as data_type,
                   a.semeste_year as data_time,
                   a.num as data_value,
                   'NO' as is_new,
                   FROM_UNIXTIME(
                        UNIX_TIMESTAMP()
                      ) AS create_time
            from
                   ( select
                        a.semeste_year,
                        a.author_code as teacher_no,
                        a.author as teacher_name,
                        count(a.patent_code) as num
                        from
                        model.scientific_author_patent_info a
                        group by  a.semeste_year,
                        a.author_code,
                        a.author
                    ) a,
                  assurance.im_quality_data_base_info c
                  where c.data_no ='${DATA_NO}'

            "
    fn_log "导入数据 —— 专利数量表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
     DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_teacher_data_info
            where data_no = '${DATA_NO}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,teacher_name,teacher_no,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_teacher_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
     clear_mysql_data "update assurance.im_quality_teacher_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}' "
    fn_log "导出数据-- 教师质控点:${HIVE_DB}.${TARGET_TABLE}"
}
##导入最新时间的数据
function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                   c.data_no as data_no,
                   c.data_name as data_name,
                   a.teacher_name as teacher_name,
                   a.teacher_no as teacher_no,
                   c.data_cycle as data_cycle,
                   c.data_type as data_type,
                   a.semeste_year as data_time,
                   a.num as data_value,
                   'NO' as is_new,
                   FROM_UNIXTIME(
                        UNIX_TIMESTAMP()
                      ) AS create_time
            from
                   ( select
                        a.semeste_year,
                        a.author_code as teacher_no,
                        a.author as teacher_name,
                        count(a.patent_code) as num
                        from
                        model.scientific_author_patent_info a
                        where a.semeste_year in
                        (select max(s.semeste_year) from model.scientific_author_patent_info s)
                        group by a.semeste_year,
                        a.author_code,
                        a.author
                    ) a,
                  assurance.im_quality_data_base_info c
                  where c.data_no ='${DATA_NO}'
            "
    fn_log "导入数据 —— 专利数量表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table_new() {
     DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_teacher_data_info
            where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,teacher_name,teacher_no,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_teacher_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
     clear_mysql_data "update assurance.im_quality_teacher_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}' "
    fn_log "导出数据-- 专利数量表:${HIVE_DB}.${TARGET_TABLE}"
}

#第1次执行脚本时执行 create_table - import_table - export_table三个函数
#第2次+以后执行脚本时执行 create_table - import_table_new - export_table_new三个函数
create_table
import_table
export_table
create_table
import_table_new
export_table_new
finish


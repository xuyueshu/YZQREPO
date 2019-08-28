#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir student_card_solution_consum_count

HIVE_DB=assurance
HIVE_TABLE=student_card_solution_consum_count
TARGET_TABLE=im_quality_student_data_info
DATA_NO=XS_YKTXFJE

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                 data_no  String comment '数据项编号',
                 data_name  String comment '数据项名称',
                 student_no  String comment '学生编号',
                 student_name String comment '学生姓名',
                 data_cycle String comment '数据统计周期  YEAR 年  MONTH 月  DAY 日  QUARTER 季度 OTHER 其他',
                 data_type String comment '数据类型  NUMBER 数值类型  ENUM 枚举类型',
                 data_time String comment '数据日期  年YYYY  月YYYYmm 日YYYYMMDD  季度YYYY-1，yyyy-2,yyyy-3,yyyy-4   学期 yyyy-yyyy  学期 yyyy-yyyy-1,yyyy-yyyy-2',
                 data_value String comment '数据项值（数字保存数字，如果是数据字典枚举保存key）',
                 is_new String comment '是否最新 是YES 否NO',
                 create_time String comment '创建时间'
    ) COMMENT '一卡通消费金额'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——一卡通消费金额表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                   c.data_no as data_no,
                   c.data_name as data_name,
                   a.student_no as student_no,
                   a.student_name as student_name,
                   c.data_cycle as data_cycle,
                   c.data_type as data_type,
                   concat(a.semester_year,'-',a.semester)  as  data_time ,
                   a.num as data_value,
                    'NO' as is_new,
                FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
            from
                 (
                      select
                      a.semester_year,
                      a.semester,
                      a.code as student_no ,
                      b.name as student_name,
                      sum(a.money) as num
                      from
                      app.student_one_card a
                      left join
                      model.basic_student_info b
                      on a.code=b.code and a.academy_code=b.academy_code
                      and a.major_code=b.major_code and a.class_code=b.class_code
                      where b.in_school='1' and b.status='1'
                      group by a.semester_year,
                      a.semester,
                      a.code,
                      b.name
                  ) a,
             assurance.im_quality_data_base_info c
             where c.data_no ='${DATA_NO}'

    "
    fn_log "导入数据 —— 一卡通消费金额表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
     DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_student_data_info
            where data_no = '${DATA_NO}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,student_no,student_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_student_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
     clear_mysql_data "update assurance.im_quality_student_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}' "
    fn_log "导出数据--学生质控点表:${HIVE_DB}.${TARGET_TABLE}"
}

function import_table_new() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
           select
                   c.data_no as data_no,
                   c.data_name as data_name,
                   a.student_no as student_no,
                   a.student_name as student_name,
                   c.data_cycle as data_cycle,
                   c.data_type as data_type,
                   concat(a.semester_year,'-',a.semester)  as  data_time ,
                   a.num as data_value,
                    'NO' as is_new,
                FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
            from
                 (
                      select
                      a.semester_year,
                      a.semester,
                      a.code as student_no ,
                      b.name as student_name,
                      sum(a.money) as num
                      from
                      app.student_one_card a
                      left join
                      model.basic_student_info b
                      on a.code=b.code and a.academy_code=b.academy_code
                      and a.major_code=b.major_code and a.class_code=b.class_code
                      where b.in_school='1' and b.status='1'  and
                      a.semester_year in
                      (select max(s.semester_year) from app.student_one_card s)
                      group by a.semester_year,
                      a.semester,
                      a.code,
                      b.name
                  ) a,
             assurance.im_quality_data_base_info c
             where c.data_no ='${DATA_NO}'
    "
    fn_log "导入数据 —— 一卡通消费金额表：${HIVE_DB}.${HIVE_TABLE}"
}

#导出新数据
function export_table_new() {
     DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_student_data_info
            where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,student_no,student_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

     clear_mysql_data "update assurance.im_quality_student_data_info set is_new = 'NO' where data_no = '${DATA_NO}';"
     clear_mysql_data "update assurance.im_quality_student_data_info set is_new = 'YES' where data_no = '${DATA_NO}' and data_time= '${DATE_TIME}' "
    fn_log "导出数据--一卡通消费金额表:${HIVE_DB}.${TARGET_TABLE}"
}
##create_table
##import_table
##export_table
#create_table
#import_table_new
#export_table_new
#finish

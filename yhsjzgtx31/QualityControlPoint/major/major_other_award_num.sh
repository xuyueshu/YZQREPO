#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir major_other_award_num

HIVE_DB=assurance
HIVE_TABLE=major_other_award_num
TARGET_TABLE=im_quality_major_data_info
DATA_NO=ZY_XSQTHJSL

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
    ) COMMENT '学生其他获奖数量'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学生其他获奖数量表：${HIVE_DB}.${HIVE_TABLE}"
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
                a.major_code,
                a.major_name,
                count(a.code) as num
                from
                app.basic_semester_student_info a
                left join app.student_award_record b on a.code=b.code
                where b.award_type = 'OTHER'
                group by a.semester_year, a.major_code,a.major_name ,a.semester
                ) a ,assurance.im_quality_data_base_info c
                where c.data_no ='${DATA_NO}'
            "
    fn_log "导入数据 —— 学生其他获奖数量表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
 DATE_TIME=`hive -e "select max(data_time) from ${HIVE_DB}.${HIVE_TABLE} " `
    clear_mysql_data "delete from im_quality_major_data_info where data_no ='${DATA_NO}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'data_no,data_name,major_no,major_name,data_cycle,data_type,data_time,data_value,is_new,create_time'

   clear_mysql_data "update assurance.im_quality_major_data_info set is_new = 'NO' where data_no ='${DATA_NO}';"
    clear_mysql_data "update assurance.im_quality_major_data_info set is_new = 'YES' where data_no ='${DATA_NO}' and data_time='${DATE_TIME}'"
    fn_log "导出数据--学校质控点数据项信息表:${HIVE_DB}.${TARGET_TABLE}"
}

#导入新数据
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
                a.major_code,
                a.major_name,
                count(a.code) as num
                from
                app.basic_semester_student_info a
                left join app.student_award_record b on a.code=b.code
                where b.award_type = 'OTHER' and  a.semester_year in
                (select max(s.semester_year) from app.basic_semester_student_info s)
                 group by a.semester_year, a.major_code,a.major_name ,a.semester
                ) a ,assurance.im_quality_data_base_info c
                where c.data_no ='${DATA_NO}'
            "
    fn_log "导入数据 —— 学生技能大赛获奖数量表：${HIVE_DB}.${HIVE_TABLE}"
}
#导出新数据
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
    fn_log "导出数据--学校质控点数据项信息表:${HIVE_DB}.${TARGET_TABLE}"
}


#create_table
#import_table
#export_table
#finish
##第一次执行 alter_table 方法
## 以后每次执行时 将 alter_table方法中 import_table export_table 方法改成
## import_table_new  export_table_new
##
##alter_table
##finish
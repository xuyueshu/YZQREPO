#!/bin/sh
###################################################
###   基础表:      学生获奖情况统计表
###   维护人:      ZhangWeiCe
###   数据源:      model.student_award_info

###  导入方式:      全量导入
###  运行命令:      sh student_award_record.sh &
###  结果目标:      app.student_award_record
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_award_record

HIVE_DB=app
HIVE_TABLE=student_award_record
TARGET_TABLE=student_award_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        code   STRING     COMMENT '学生编号',
                        semester_year   STRING     COMMENT '学年',
                        semester   STRING     COMMENT '学期',
                        award_type   STRING     COMMENT '获奖类型,参见enum_info中HY类型的枚举,保存对应code',
                        get_time   STRING     COMMENT '获取时间(yyyy-mm-dd)',
                        award_level   STRING     COMMENT '获奖级别' )COMMENT  '学生获奖情况统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生获奖情况统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
                    distinct
                    code,
                    semester_year,
                    nvl(semester,1) as semester,
                    award_type,
                    award_time as get_time,
                    nvl(award_level,' ') as award_level
              from model.student_award_info
        "
        fn_log " 导入数据--学生获奖情况统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,semester_year,semester,award_type,get_time,award_level"

    fn_log "导出数据--学生获奖情况统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
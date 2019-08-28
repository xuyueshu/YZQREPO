#!/bin/sh
###################################################
###   基础表:      学生上网时长明细表
###   维护人:      ZhangWeiCe
###   数据源:      model.basic_network_record,model.basic_semester_info

###  导入方式:      全量导入
###  运行命令:      sh student_netPlay_record.sh &
###  结果目标:      app.student_netPlay_record
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_netPlay_record

HIVE_DB=app
HIVE_TABLE=student_netPlay_record
TARGET_TABLE=student_netPlay_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        code   STRING     COMMENT '学生编号',
                        semester_year   STRING     COMMENT '学年',
                        semester   STRING     COMMENT '学期',
                        workday_netPlay_hours   STRING     COMMENT '工作日上网小时数',
                        weekend_netPlay_hours   STRING     COMMENT '周末上网小时数',
                        statistics_month   STRING     COMMENT '统计月份(yyyy-mm)')COMMENT  '学生上网时长明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生上网时长明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            student_code as code,
            semester_year,
            semester,
            SUM(case when
            pmod(datediff(SUBSTR(on_line_time,1,10), '2019-01-01') + 2, 7)!=0
            or pmod(datediff(SUBSTR(on_line_time,1,10), '2019-01-01') + 2, 7)!=6
                then time_long else 0 end) as workday_netPlay_hours,
            SUM(case when pmod(datediff(SUBSTR(on_line_time,1,10), '2019-01-01') + 2, 7)=0
            or pmod(datediff(SUBSTR(on_line_time,1,10), '2019-01-01') + 2, 7)=6
                then time_long else 0 end) as weekend_netPlay_hours,
                SUBSTR(on_line_time,1,7) as statistics_month
        FROM
            model.basic_network_record,model.basic_semester_info
            WHERE on_line_time BETWEEN begin_time and end_time
            GROUP BY student_code,statistics_month
        "
        fn_log " 导入数据--学生上网时长明细表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,semester_year,semester,workday_netPlay_hours,weekend_netPlay_hours,statistics_month"

    fn_log "导出数据--学生上网时长明细表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
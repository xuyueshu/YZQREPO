#!/bin/sh
###################################################
###   基础表:      学生上网时间统计表
###   维护人:      ZhangWeiCe
###   数据源:      app.student_netPlay_record,model.basic_student_info

###  导入方式:      全量导入
###  运行命令:      sh student_playnet_time_avg.sh &
###  结果目标:      app.student_playnet_time_avg
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_playnet_time_avg

HIVE_DB=app
HIVE_TABLE=student_playnet_time_avg
TARGET_TABLE=student_playnet_time_avg

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                    academy_code   STRING     COMMENT '系编号',
                    major_code   STRING     COMMENT '专业编号',
                    class_code   STRING     COMMENT '班级编号',
                    avg_hour   STRING     COMMENT '班级平均上网小时',
                    statistics_month   STRING     COMMENT '统计月份(yyyy-mm)',
                    semester_year   STRING     COMMENT '学年',
                    semester   STRING     COMMENT '学期')COMMENT  '学生上网时间统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生上网时间统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            t2.academy_code AS academy_code,
            t2.major_code AS major_code,
            t2.class_code AS class_code,
            ROUND((SUM(t1.workday_netPlay_hours+t1.weekend_netPlay_hours)/t3.num),2)  AS avg_hour,
            t1.statistics_month AS statistics_month,
            t1.semester_year AS semester_year,
            t1.semester AS semester
        FROM app.student_netPlay_record t1
        left join
            model.basic_student_info t2 on t1.code=t2.code
            left join
            (SELECT class_code,count(1) as num FROM model.basic_student_info
                GROUP BY class_code) t3 on t3.class_code=t2.class_code
            GROUP BY t2.class_code
        "
        fn_log " 导入数据--学生上网时间统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,avg_hour,statistics_month,semester_year,semester"

    fn_log "导出数据--学生上网时间统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
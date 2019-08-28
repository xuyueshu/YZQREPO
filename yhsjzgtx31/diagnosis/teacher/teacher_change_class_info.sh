#!/bin/sh
###################################################
###   基础表:      教师课程调整信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_change_class_info.sh &
###  结果目标:      model.teacher_change_class_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_change_class_info

HIVE_DB=model
HIVE_TABLE=teacher_change_class_info
TARGET_TABLE=teacher_change_class_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        course_code   STRING     COMMENT '课程编号',
                                        course_name   STRING     COMMENT '课程名称',
                                        weekly_times   STRING     COMMENT '周次',
                                        festivals   STRING     COMMENT '节次',
                                        status   STRING     COMMENT '调课结果',
                                        course_number   STRING     COMMENT '课序号',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        single_double_week   STRING     COMMENT '单双周',
                                        week_day   STRING     COMMENT '星期几',
                                        cousre_type   STRING     COMMENT '调课类型 tk调课，dk代课，sg事故',
                                        class_time   STRING     COMMENT '上课时间(yyyy-mm-dd)',
                                        reason   STRING     COMMENT '调课原因（1:因公，2:因私，0:非调课）')COMMENT  '教师课程调整信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师课程调整信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
                  select YDLJSBH code,
                         YDLJSXM name,
                         KCBH course_code,
                         KCMC course_name,
                         weekofyear(concat(concat(substr(TKSJ,1,4),'-',substr(TKSJ,5,2)),'-',substr(TKSJ,7,2))) weekly_times,
                         2 festivals,
                         1 status,
                         BJBH course_number,
                         XN semester_year,
                         XQ semester,
                         case when cast(weekofyear(concat(concat(substr(TKSJ,1,4),'-',substr(TKSJ,5,2)),'-',substr(TKSJ,7,2))) as int)/2=0 then 2 else 1 end single_double_week,
                         case when pmod(datediff(concat(concat(substr(TKSJ,1,4),'-',substr(TKSJ,5,2)),'-',substr(TKSJ,7,2)), '2012-01-01'), 7)=0 then 7 else
                              pmod(datediff(concat(concat(substr(TKSJ,1,4),'-',substr(TKSJ,5,2)),'-',substr(TKSJ,7,2)), '2012-01-01'), 7) end week_day,
                         case when trim(TDKLX)='1' then 'tk' when trim(TDKLX)='2' then 'dk' end cousre_type,
                         TKSJ class_time,
                         TKYY reason
                  from raw.zgy_t_zg_jstdkxx
        "
        fn_log " 导入数据--教师课程调整信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,course_code,course_name,weekly_times,festivals,status,course_number,semester_year,semester,single_double_week,week_day,cousre_type,class_time,reason"

    fn_log "导出数据--教师课程调整信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
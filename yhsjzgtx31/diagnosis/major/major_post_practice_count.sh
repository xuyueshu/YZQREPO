#!/bin/sh
###################################################
###   基础表:      专业顶岗实习统计表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_post_practice_count.sh &
###  结果目标:      model.major_post_practice_count
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_post_practice_count

HIVE_DB=model
HIVE_TABLE=major_post_practice_count
TARGET_TABLE=major_post_practice_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        dept_code   STRING     COMMENT '系代码',
                                        dept_name   STRING     COMMENT '系名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称',
                                        semester_year   STRING     COMMENT '学年',
                                        enroll_students_proportion   STRING     COMMENT '顶岗实习录取学生比例（上一届）',
                                        students_proportion   STRING     COMMENT '顶岗实习学生比例(当前界)',
                                        achievement_avg   STRING     COMMENT '顶岗实习学生平均成绩',
                                        monthly_submission_rate_average   STRING     COMMENT '顶岗实习月报平均提交率',
                                        sign_in_rate_avg   STRING     COMMENT '顶岗实习平均签到率',
                                        monthly_marking_rate_average   STRING     COMMENT '顶岗实习月报平均批阅率',
                                        weekly_submission_rate_average   STRING     COMMENT '顶岗实习周报平均提交率',
                                        weekly_marking_rate_average   STRING     COMMENT '顶岗实习周报平均批阅率',
                                        enroll_students_num   STRING     COMMENT '顶岗实习录取学生人数（上一届）',
                                        post_practice_students_num   STRING     COMMENT '顶岗实习学生人数(当前界)',
                                        sign_in__num   STRING     COMMENT '顶岗实习签到人数'        )COMMENT  '专业顶岗实习统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业顶岗实习统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}"
        fn_log " 导入数据--专业顶岗实习统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "dept_code,dept_name,major_code,major_name,semester_year,enroll_students_proportion,students_proportion,achievement_avg,monthly_submission_rate_average,sign_in_rate_avg,monthly_marking_rate_average,weekly_submission_rate_average,weekly_marking_rate_average,enroll_students_num,post_practice_students_num,sign_in__num"

    fn_log "导出数据--专业顶岗实习统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
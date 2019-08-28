#!/bin/sh
###################################################
###   基础表:      学生社会实践活动信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_social_activity.sh &
###  结果目标:      model.student_social_activity
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_social_activity

HIVE_DB=model
HIVE_TABLE=student_social_activity
TARGET_TABLE=student_social_activity

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '系部编号',
                                        major_code   STRING     COMMENT '专业编号',
                                        class_code   STRING     COMMENT '班级编号',
                                        code   STRING     COMMENT '学生编号',
                                        practice_company   STRING     COMMENT '实践单位',
                                        practice_address   STRING     COMMENT '实践地点',
                                        practice_project   STRING     COMMENT '实践项目',
                                        start_time   STRING     COMMENT '实践开始时间(yyyy-MM-dd)',
                                        end_time   STRING     COMMENT '实践结束时间(yyyy-MM-dd)',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期'        )COMMENT  '学生社会实践活动信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生社会实践活动信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}"
        fn_log " 导入数据--学生社会实践活动信息表: ${HIVE_DB}.${HIVE_TABLE}"

}



init_exit
create_table
import_table
finish
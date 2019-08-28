#!/bin/sh
###################################################
###   基础表:      教师指导扶贫明细表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_guidance_help_record.sh &
###  结果目标:      app.teacher_guidance_help_record
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_guidance_help_record

HIVE_DB=model
HIVE_TABLE=teacher_guidance_help_record
TARGET_TABLE=teacher_guidance_help_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        student_code   STRING     COMMENT '学生编号',
                                        help_type   STRING     COMMENT '毕业设计/专业实训/扶贫'        )COMMENT  '教师指导扶贫明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师指导扶贫明细表: ${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester_year,student_code,help_type"

    fn_log "导出数据--教师指导扶贫明细表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
export_table
finish
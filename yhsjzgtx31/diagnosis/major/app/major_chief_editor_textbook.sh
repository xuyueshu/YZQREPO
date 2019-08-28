#!/bin/sh
###################################################
###   基础表:      专业主编教材信息表
###   维护人:      ZhangWeiCe
###   数据源:      model.basic_textbook_info

###  导入方式:      全量导入
###  运行命令:      sh major_chief_editor_textbook.sh &
###  结果目标:      app.major_chief_editor_textbook
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_chief_editor_textbook

HIVE_DB=app
HIVE_TABLE=major_chief_editor_textbook
TARGET_TABLE=major_chief_editor_textbook

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                    major_code   STRING     COMMENT '专业编号',
                    major_name   STRING     COMMENT '专业名称',
                    academy_code   STRING     COMMENT '学院编号',
                    academy_name   STRING     COMMENT '学院名称',
                    textbooks_type   STRING     COMMENT '教材的类型，参见emnu_info中JCLX类型的枚举，保存对应code',
                    textbook_count   STRING     COMMENT '教材数量',
                    semester_year   STRING     COMMENT '学年',
                    semester   STRING     COMMENT '学期 1 第一学期 2 第二学期')COMMENT  '专业主编教材信息表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业主编教材信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            major_code as major_code,
            major_name as major_name,
            academy_code as academy_code,
            academy_name as academy_name,
            type as textbooks_type,
            count(1) as textbook_count,
            semester_year as semester_year,
            semester as semester
        FROM model.basic_textbook_info
        GROUP BY major_code,type,major_name,academy_code,academy_name,semester_year,semester,textbook_code
        "
        fn_log " 导入数据--专业主编教材信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "major_code,major_name,academy_code,academy_name,textbooks_type,textbook_count,semester_year,semester"

    fn_log "导出数据--专业主编教材信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
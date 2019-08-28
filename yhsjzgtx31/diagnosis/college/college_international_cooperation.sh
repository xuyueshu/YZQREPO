#!/bin/sh
###################################################
###   基础表:      学院国际合作统计表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_international_cooperation.sh &
###  结果目标:      model.college_international_cooperation
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_international_cooperation

HIVE_DB=model
HIVE_TABLE=college_international_cooperation
TARGET_TABLE=college_international_cooperation

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        project_num   STRING     COMMENT '合作交流项目数',
                                        activity_num   STRING     COMMENT '国际合作交流活动数量',
                                        abroad_train_num   STRING     COMMENT '出国(境)培训人数',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期'        )COMMENT  '学院国际合作统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院国际合作统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

#t_zg_gjhzjlyhdqk表中缺少abroad_train_num，以及semester_year和semester
function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
           select
                HZJLS project_num,
                HDQKS activity_num,
                0 abroad_train_num,
                concat(nd,'-',cast(nd as int)+1) semester_year,
                2 semester
           from raw.ic_t_zg_gjhzjlyhdqk
        "
    fn_log "导入数据--学院基本信息表:${HIVE_DB}.${HIVE_TABLE}"
}


function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "project_num,activity_num,abroad_train_num,semester_year,semester"

    fn_log "导出数据--学院国际合作统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
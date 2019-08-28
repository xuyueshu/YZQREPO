#!/bin/sh
###################################################
###   基础表:      学院数字化校园建设统计表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_digital_campus.sh &
###  结果目标:      model.college_digital_campus
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_digital_campus

HIVE_DB=model
HIVE_TABLE=college_digital_campus
TARGET_TABLE=college_digital_campus

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        server_num   STRING     COMMENT '服务器数量',
                                        computer_room_num   STRING     COMMENT '机房数量',
                                        business_system_construction_num   STRING     COMMENT '业务系统建设数量',
                                        export_broadband   STRING     COMMENT '出口宽带（兆）',
                                        broadband_access   STRING     COMMENT '入口宽带（兆）',
                                        hardware_investment_money   STRING     COMMENT '数字校园硬件建设投资金额（万元）',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '学院数字化校园建设统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院数字化校园建设统计表: ${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "server_num,computer_room_num,business_system_construction_num,export_broadband,broadband_access,hardware_investment_money,semester_year"

    fn_log "导出数据--学院数字化校园建设统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
export_table
finish
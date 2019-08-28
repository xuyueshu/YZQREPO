#!/bin/sh
###################################################
###   基础表:      出入境人员明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_exit_record.sh &
###  结果目标:      model.college_exit_record
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_exit_record

HIVE_DB=model
HIVE_TABLE=college_exit_record
TARGET_TABLE=college_exit_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '人员编号（老师/学生）',
                                        name   STRING     COMMENT '姓名',
                                        country   STRING     COMMENT '出访国家',
                                        reason   STRING     COMMENT '出访原因',
                                        project_name   STRING     COMMENT '项目名称',
                                        project_code   STRING     COMMENT '项目编号',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        visit_time   STRING     COMMENT '出访时间(yyyy-mm-dd)',
                                        return_time   STRING     COMMENT '返回时间(yyyy-mm-dd)',
                                        visit_days   STRING     COMMENT '出访天数',
                                        type   STRING     COMMENT '人员类型(1老师,2学生)'        )COMMENT  '出入境人员明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--出入境人员明细表: ${HIVE_DB}.${HIVE_TABLE}"
}
#空字符的字段都是t_zg_gjhzxx表中没有该字段信息的
function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
           select
                '' code,
                '' name,
                '' country,
                XMMC reason,
                XMMC project_name,
                XMBH project_code,
                XN semester_year,
                XQ semester,
                '' visit_time,
                '' return_time,
                RRRSCYTS visit_days,
                CASE WHEN RYLX='学生' then 2 else 1 end  type
           from raw.ic_t_zg_gjhzxx
        "
    fn_log "导入数据--学院基本信息表:${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,country,reason,project_name,project_code,semester_year,semester,visit_time,return_time,visit_days,type"

    fn_log "导出数据--出入境人员明细表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
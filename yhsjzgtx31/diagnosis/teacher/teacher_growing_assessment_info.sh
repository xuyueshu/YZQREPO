#!/bin/sh
###################################################
###   基础表:      教师成长考核表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_growing_assessment_info.sh &
###  结果目标:      app.teacher_growing_assessment_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_growing_assessment_info

HIVE_DB=model
HIVE_TABLE=teacher_growing_assessment_info
TARGET_TABLE=teacher_growing_assessment_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        assessment_score   STRING     COMMENT '年度考核分数',
                                        character_score   STRING     COMMENT '师德考核分数',
                                        occur_time   STRING     COMMENT '发生时间'        )COMMENT  '教师成长考核表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师成长考核表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
            GH code,
            XM name,
            concat(nvl(cast(nd as int),2018),'-',nvl(cast(nd as int),2018)+1) semester_year,
            case when KHFS is not null then cast(KHFS as int) when KHJG='优秀' then 85 when KHJG='合格' then 60 when KHJG='不合格' then 59 else 0 end  assessment_score,
            nvl(cast(SDKHFS as int),0) character_score,
            case when CLRQ is not null then substr(CLRQ,1,19) else from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') end occur_time
        from raw.te_t_jzg_ndkh
        "
        fn_log " 导入数据--教师课表数据表: ${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester_year,assessment_score,character_score,occur_time"

    fn_log "导出数据--教师成长考核表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
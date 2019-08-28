#!/bin/sh
###################################################
###   基础表:      科研项目参与人员表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_teaching_research_personnel_info.sh &
###  结果目标:      app.teacher_teaching_research_personnel_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_teaching_research_personnel_info

HIVE_DB=model
HIVE_TABLE=teacher_teaching_research_personnel_info
TARGET_TABLE=teacher_teaching_research_personnel_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师名称',
                                        project_code   STRING     COMMENT '项目编号',
                                        participate_type   STRING     COMMENT '参与类型：1主持，2参与',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '科研项目参与人员表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--科研项目参与人员表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select distinct
                nvl(a.FUNCTIONARY_NO,'') code,
                nvl(a.FUNCTIONARY_NAME,'') name,
                nvl(a.PROJECT_NO,'') project_code,
                1 participate_type,
                case when length(a.SETUP_DATE)=6 then concat(cast(substring(a.SETUP_DATE,1,4) as int),'-',cast(substring(a.SETUP_DATE,1,4) as int)+1)
                     else concat(cast(concat('20',substring(a.PROJECT_NO,1,2)) as int),'-',cast(concat('20',substring(a.PROJECT_NO,1,2)) as int)+1) end semester_year
        from raw.sr_t_ky_kyxmxx a
        "
        fn_log " 导入数据--科研项目参与人员表: ${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,project_code,participate_type,semester_year"

    fn_log "导出数据--科研项目参与人员表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
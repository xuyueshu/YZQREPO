#!/bin/sh
###################################################
###   基础表:      专业教学资源信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_instructional_resources.sh &
###  结果目标:      model.major_instructional_resources
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_instructional_resources

HIVE_DB=model
HIVE_TABLE=major_instructional_resources
TARGET_TABLE=major_instructional_resources

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业的名称',
                                        academy_code   STRING     COMMENT '学院编号',
                                        academy_name   STRING     COMMENT '学院的名称',
                                        national_resourses_count   STRING     COMMENT '国家级资源个数',
                                        provincial_resources_count   STRING     COMMENT '省级资源个数',
                                        college_resources_count   STRING     COMMENT '院级资源个数',
                                        semester   STRING     COMMENT '学期 1是第一学期2是第二学期',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '专业教学资源信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业教学资源信息表: ${HIVE_DB}.${HIVE_TABLE}"
}
#T_ZG_ZYJXZYK原始库没有semester学期字段
function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select ZYBH major_code,ZYMC major_name,YBBH academy_code,YBMC academy_name,
            sum(case when ZYKDJ='国家级' then 1 else 0 end) national_resourses_count,
            sum(case when ZYKDJ='省级' then 1 else 0 end) provincial_resources_count,
            sum(case when ZYKDJ='院级' then 1 else 0 end) college_resources_count,
            1 semester,
            XN semester_year
            from raw.te_t_zg_zyjxzyk
            group by ZYBH,ZYMC,YBBH,YBMC,XN
        "
        fn_log " 导入数据--专业教学资源信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "major_code,major_name,academy_code,academy_name,national_resourses_count,provincial_resources_count,college_resources_count,semester,semester_year"

    fn_log "导出数据--专业教学资源信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
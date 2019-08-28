#!/bin/sh
###################################################
###   基础表:      实训项目信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_trainingProject_detailed.sh &
###  结果目标:      model.major_trainingProject_detailed
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_trainingProject_detailed

HIVE_DB=model
HIVE_TABLE=major_trainingProject_detailed
TARGET_TABLE=major_trainingProject_detailed

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        dept_code   STRING     COMMENT '系代码',
                                        dept_name   STRING     COMMENT '系名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称',
                                        semester_year   STRING     COMMENT '学年',
                                        plan_hours   STRING     COMMENT '计划课时',
                                        actual_hours   STRING     COMMENT '实际课时',
                                        semester   STRING     COMMENT '学期',
                                        project_name   STRING     COMMENT '项目名称',
                                        is_open   STRING     COMMENT '是否开出（0：否1：是）',
                                        course_code   STRING     COMMENT '课程编号'        )COMMENT  '实训项目信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--实训项目信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

#课程实训教学信息表（T_ZG_KCSXJXXXB）
#该课程都实训了那些项目呢？于实训项目表关联不上，差个项目名称或者编号
#项目是否开出？推送过来的数据有空值
function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select
            distinct
            a.SSXBBH  as dept_code,
            a.SSXB as dept_name,
            a.ZYBH as major_code,
            a.ZYMC as major_name,
            a.XNMC as semester_year,
            nvl(a.JHKS,0) as plan_hours,
            nvl(a.SJSXKS,0) as actual_hours,
            a.XQMC as semester,
            a.SXXMMC as project_name,
            cast(1 as decimal) as is_open,
            ' '  as course_code
            from
            raw.zgy_T_ZG_SXXMXXB a

        "
        fn_log " 导入数据--实训项目信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "dept_code,dept_name,major_code,major_name,semester_year,plan_hours,actual_hours,semester,project_name,is_open,course_code"

    fn_log "导出数据--实训项目信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
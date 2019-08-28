#!/bin/sh
###################################################
###   基础表:      教师参与资源建设明细表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_resource_build_info.sh &
###  结果目标:      app.teacher_resource_build_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_resource_build_info

HIVE_DB=model
HIVE_TABLE=teacher_resource_build_info
TARGET_TABLE=teacher_resource_build_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        resource_name   STRING     COMMENT '资源名称',
                                        resource_code   STRING     COMMENT '资源编号',
                                        semester_year   STRING     COMMENT '学年',
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师名称',
                                        dept_name   STRING     COMMENT '系部名称',
                                        dept_code   STRING     COMMENT '系部编号',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        resource_type   STRING     COMMENT '资源类别，见枚举表RESOURCETYPE'        )COMMENT  '教师参与资源建设明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师参与资源建设明细表: ${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "resource_name,resource_code,semester_year,code,name,dept_name,dept_code,major_code,major_name,resource_type"

    fn_log "导出数据--教师参与资源建设明细表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
export_table
finish
#!/bin/sh
###################################################
###   基础表:      社团信息表
###   维护人:      Guojianing
###   数据源:      model.student_community_information&&model.student_join_community&&model.basic_teacher_info

###  导入方式:      全量导入
###  运行命令:      sh teacher_community_info.sh &
###  结果目标:      app.teacher_community_info
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir teacher_community_info

HIVE_DB=app
HIVE_TABLE=teacher_community_info
TARGET_TABLE=teacher_community_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编码',
                                        name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        community_name   STRING     COMMENT '社团名称',
                                        create_time   STRING     COMMENT '成立时间',
                                        student_num   STRING     COMMENT '学生人数',
                                        honorary_title   STRING     COMMENT '荣誉称号 ',
                                        remark   STRING     COMMENT ''        )COMMENT  '社团信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--社团信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
            aa.teacher_code as code,
            cc.name,
            aa.semester_year,
            aa.name as community_name,
            aa.create_time,
            bb.num as student_num,
            aa.honorary_title,
            '' remark
from  model.student_community_information  aa
        left join
(select count(1) as num,community_code,semester_year
from model.student_join_community group by community_code,semester_year) bb
on aa.code= bb.community_code and aa.semester_year= bb.semester_year
left join
model.basic_teacher_info cc
on  cc.code =aa.teacher_code and cc.semester_year=aa.teacher_code
        "
        fn_log " 导入数据--社团信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester_year,community_name,create_time,student_num,honorary_title,remark"

    fn_log "导出数据--社团信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
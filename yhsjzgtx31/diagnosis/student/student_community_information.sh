#!/bin/sh
###################################################
###   基础表:      社团基本信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_community_information

HIVE_DB=model
HIVE_TABLE=student_community_information
TARGET_TABLE=student_community_information

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              name      STRING    COMMENT '社团名称',
              create_time      STRING    COMMENT '成立日期',
              leader      STRING    COMMENT '社团负责人号',
              teacher_code      STRING    COMMENT '指导教师号',
              semester_year      STRING    COMMENT '学年',
              honorary_title STRING COMMENT '荣誉称号',
             code  STRING  COMMENT '社团编号'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "社团基本信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}

function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        "
        fn_log " 导入数据--社团基本信息表:${HIVE_DB}.${HIVE_TABLE}"

}



init_exit
create_table
import_table
finish
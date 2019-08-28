#!/bin/sh
###################################################
###   基础表:      学生参与社团信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_join_community

HIVE_DB=model
HIVE_TABLE=student_join_community
TARGET_TABLE=student_join_community

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              student_code      STRING    COMMENT '学生编号',
              community_code      STRING    COMMENT '社团编号',
              join_time      STRING    COMMENT '加入社团时间',
              leave_time      STRING    COMMENT '离开时间',
              semester_year      STRING    COMMENT '学年',
              semester     STRING    COMMENT '学期'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生参与社团信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}

function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        "
        fn_log " 导入数据--学生参与社团信息表:${HIVE_DB}.${HIVE_TABLE}"

}



init_exit
create_table
import_table
finish
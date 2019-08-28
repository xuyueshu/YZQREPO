#!/bin/sh
###################################################
###   基础表:      党员活动信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir party_activity_info

HIVE_DB=model
HIVE_TABLE=party_activity_info
TARGET_TABLE=party_activity_info

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              place      STRING    COMMENT '活动地点',
              join_people      STRING    COMMENT '参与人',
              topic      STRING    COMMENT '活动主题',
              planner      STRING    COMMENT '活动策划人',
              master      STRING    COMMENT '主持人',
              activity_time      STRING    COMMENT '活动时间',
              semester_year      STRING    COMMENT '学年'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "党员活动信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}

function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        "
        fn_log " 导入数据--党员活动信息表:${HIVE_DB}.${HIVE_TABLE}"

}



init_exit
create_table
import_table
finish
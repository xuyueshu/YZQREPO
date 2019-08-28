#!/bin/sh
###################################################
###   基础表:      党员荣誉信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir party_honor_info

HIVE_DB=model
HIVE_TABLE=party_honor_info
TARGET_TABLE=party_honor_info

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              name      STRING    COMMENT '荣誉名称',
              level      STRING    COMMENT '等级',
              teamer      STRING    COMMENT '团体或个人',
              honor_time      STRING    COMMENT '获取荣誉时间',
              semester_year      STRING    COMMENT '学年'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "党员荣誉信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}

function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        "
        fn_log " 导入数据--党员荣誉信息表:${HIVE_DB}.${HIVE_TABLE}"

}


init_exit
create_table
import_table
finish
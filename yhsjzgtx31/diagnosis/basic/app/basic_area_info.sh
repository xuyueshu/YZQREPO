#!/bin/sh
#################################################
###  基础表:       地区编号信息表
###  维护人:       王浩
###  数据源:       自行整理

###  导入方式:      全量
###  运行命令:      sh basic_area_info.sh. &
###  结果目标:      app.basic_area_info
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir basic_area_info

HIVE_DB=app
HIVE_TABLE=basic_area_info
TARGET_TABLE=basic_area_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
						code STRING COMMENT '行政区划代码',
						name STRING COMMENT '行政区划名称',
						parent_id STRING COMMENT '父级ID'
      )COMMENT '地区基础信息表'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "
    fn_log "CREATE EXTERNAL TABLE:${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

    hive -e "LOAD DATA LOCAL INPATH './basic_area_info.csv' INTO TABLE ${HIVE_DB}.${HIVE_TABLE};"
    fn_log "IMPORT TABLE:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by ',' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,parent_id"

    fn_log "EXPORT TABLE:${HIVE_DB}.${TARGET_TABLE}"
}


create_table
import_table
export_table
finish
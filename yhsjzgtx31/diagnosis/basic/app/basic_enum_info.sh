#!/bin/sh
#################################################
###  基础表:       枚举基础信息表
###  维护人:       王浩
###  数据源:       自行整理

###  导入方式:      全量导入
###  运行命令:      sh basic_enum_info.sh. &
###  结果目标:      app.basic_enum_info
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir basic_enum_info

HIVE_DB=app
HIVE_TABLE=basic_enum_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            id STRING COMMENT '',
            code STRING COMMENT '枚举代码',
            name STRING COMMENT '枚举名称',
            parent_code STRING COMMENT '父级枚举代码',
            parent_name STRING COMMENT '父级枚举名称',
            status STRING COMMENT '状态:0可用,1不可用'
      )COMMENT '枚举基础信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "create :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
    sqoop import --hive-import --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} --driver com.mysql.jdbc.Driver --table basic_enum_info  --hive-table app.basic_enum_info -m 1 --hive-overwrite --input-null-string '\\N' --input-null-non-string '\\N' --hive-drop-import-delims --null-string '\\N' --null-non-string '\\N' --fields-terminated-by '\0001'
    fn_log "import :${HIVE_DB}.${HIVE_TABLE}"
}

create_table
import_table
finish
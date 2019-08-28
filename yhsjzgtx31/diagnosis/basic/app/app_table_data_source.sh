#!/bin/sh
#################################################
###
#################################################
cd `dirname $0`

#exec_dir basic_table_data_source
source ./basic_semester_student_info.sh
#source ../../../config.sh

DATA=app_table_data_source
TARGET_TABLE=basic_table_data_source
#app层用   HIVE_DB 变量
#model层用 MODEL_DB 变量 以逗号（，）分割
#RUN_SHELL="
#basic_semester_student_info.sh
#"

function doconmand(){
    start=$(date +%s)
    #读取文件的每一行
	for comand in ${comands}
	do
	    source ./$comand
	    create_table
        #导入数据
	    import_table
        export_table
	    end=$(date +%s)
		 if [ $? -eq 0 ]; then
	    	echo " $comand succeed>>>  耗时$(( $end - $start ))s " >>  ${LOG_RUN_PATH} 2>&1
		 else
		    echo " $comand failed>>>  耗时$(( $end - $start ))s "  >>  ${LOG_RUN_PATH} 2>&1;
		    echo " ## sh $comand 错误  exit 1  ##"  >>  ${LOG_RUN_PATH} 2>&1;
		    exit 1;
		 fi

	done
	end=$(date +%s)
	echo " 耗时$(( $end - $start ))s" >>  ${LOG_RUN_PATH} 2>&1
	#删除脚本执行过程中产生的Java文件
	rm -rf *.java
}

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_TABLE}/${DATA} || :
        hive -e "DROP TABLE IF EXISTS app.app_table_data_source;"
        hive -e "CREATE TABLE IF NOT EXISTS app.app_table_data_source(
                  table_name   STRING   COMMENT 'app表',
                  data_source STRING   COMMENT 'model数据源',
                  create_time STRING COMMENT '创建时间'
                 )COMMENT  'app来源信息表'
LOCATION '${BASE_HIVE_DIR}/app/app_table_data_source'"

        fn_log "创建表--app来源信息表:${HIVE_DB}.${DATA}"
}
#导入数据
function import_table() {


    hive -e "
        INSERT INTO ${HIVE_DB}.${DATA}
        select
        a.table_name,
        tag_new as data_source,
        FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
        from
        (select '${HIVE_TABLE}' as table_name,'${MODEL_DB}' as data_source) a
        lateral view explode(split('${MODEL_DB}',',')) num as tag_new
    "
    fn_log "导入表--app来源信息表: ${HIVE_DB}.${DATA}"
}
#导出数据
function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${TARGET_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "table_name,data_source,create_time"

    fn_log "导出数据--app层数据来源信息表: ${HIVE_DB}.${TARGET_TABLE}"

}
create_table
        #导入数据
	    import_table
        export_table


#currentPath=/root/etl/SXNYZY/diagnosis/basic/app
#
#comands=()
#
#if [ $? -eq 0 ]; then
#	cd  $currentPath
#comands=${RUN_SHELL[*]}
##doconmand
#create_table
#        #导入数据
#	    import_table
#        export_table
#
#fi
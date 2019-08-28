#!/bin/sh
#################################################
###  基础表:       学生上网流水表
###  维护人:       师立朋
###  数据源:

###  导入方式:      增量导入
###  运行命令:      sh basic_network_record.sh
###  结果目标:      model.basic_network_record
#################################################
#cd `dirname $0`
source ../../config.sh
#exec_dir basic_network_record


HIVE_DB=model
HIVE_TABLE=basic_network_record
MYCAT_TABLE=basic_network_record

function create_table(){
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

    hive -e "
        CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            student_code STRING COMMENT '学生编号',
            on_line_time STRING COMMENT '上线时间',
            off_line_time STRING COMMENT '下线时间',
            time_long STRING COMMENT '在线时长',
            total_bytes bigint COMMENT '总流量',
            ip STRING COMMENT 'ip地址',
            mac STRING COMMENT 'mac地址'
             )
        COMMENT '学生上网流水表'
        partitioned by(semester_year string,semester string)
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建表--学生上网流水表:${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

    fn_log "${1}-------${2}"

    hive -e "ALTER TABLE ${HIVE_DB}.${HIVE_TABLE} DROP IF EXISTS PARTITION(semester_year='${1}',semester='${2}')"

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}/semester_year=${1}/semester=${2}/ || :

    fn_log "删除分区原有数据:${1}${2}"

    #   样例

         hive -e "
        SET hive.exec.dynamic.partition=true;
        SET hive.exec.dynamic.partition.mode=nonstrict;
        SET hive.exec.max.dynamic.partitions.pernode=1000;
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE} partition(semester_year,semester)
        SELECT
            trim(c.username) as student_code,
            substr(c.logintime,0,19) as on_line_time,
			substr(c.logouttime,0,19) as off_line_time,
			c.time as time_long,
			c.flow as total_bytes,
			c.ipv4 as ip,
            concat_ws('-',substr(c.mac,1,2),substr(c.mac,3,2),substr(c.mac,5,2),substr(c.mac,7,2),substr(c.mac,9,2),substr(c.mac,11,2)) as mac, 
            si.semester_year,
            si.semester
        FROM
            raw_drcom.viewuserloginhistory c
            LEFT JOIN model.basic_semester_info si
        WHERE
            substr(c.logouttime,0,19) BETWEEN si.begin_time and si.end_time
    "

    fn_log "导入数据--学生上网流水表:${HIVE_DB}.${HIVE_TABLE}"
}
###全量导出到mycat
function insert_mycat_table_all(){

	DIRPATH="${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}/*/*"

	sqoop export --connect ${MYCAT_URL} --username ${MYCAT_USERNAME} --password ${MYCAT_PASSWORD} --table ${MYCAT_TABLE} \
	--export-dir ${DIRPATH} --input-fields-terminated-by '\001' --lines-terminated-by '\n' --input-null-string '\\N' --input-null-non-string '\\N' \
	--columns "student_code,on_line_time,off_line_time,time_long,total_bytes,ip,mac"
}

####增量导出到mycat
function insert_mycat_table(){
	# 清除原来的数据
	if [ ${#1} == 6 ];then
		MONTH=$1
		DELSQL="DELETE FROM ${MYCAT_TABLE} WHERE month = ${MONTH}";
		DIRPATH="${BASE_HIVE_DIR}/${HIVE_DB}.db/${HIVE_TABLE}/sharding_month=${MONTH}/*/*"
	else
		MONTH=`date -d "$1" +"%Y%m"`
		DAY=`date -d "$1" +"%Y%m%d"`
		DELSQL="DELETE FROM ${MYCAT_TABLE} WHERE month = ${MONTH} AND day = ${DAY};"
		DIRPATH="${BASE_HIVE_DIR}/${HIVE_DB}.db/${HIVE_TABLE}/sharding_month=${MONTH}/sharding_day=${DAY}/*"
	fi

	${MYCAT_CONN} -e "${DELSQL};"

	sqoop export --connect ${MYCAT_URL} --username ${MYCAT_USERNAME} --password ${MYCAT_PASSWORD} --table ${MYCAT_TABLE} \
	--export-dir ${DIRPATH} --input-fields-terminated-by '\001' --lines-terminated-by '\n' --input-null-string '\\N' --input-null-non-string '\\N' \
	--columns "card_code,holder_code,store_code,store_name,eq_code,record_time,money,\
	operate_type_code,operate_type_name,balance,month,day"
}

#init_exit
#create_table
#import_table `cur_se_year_by_sort` `cur_sem_by_sort`
insert_mycat_table_all
finish




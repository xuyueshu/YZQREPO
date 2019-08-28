#!/bin/sh
#################################################
###  功能:全局变量定义
###  维护人:宋敏锋
#################################################

#PATH="/sunmnet/xtcj"

BASE_HIVE_DIR=/user/hueoperator
#BASE_HIVE_DIR=/user/hive/warehouse

# mycat服务信息
#MYCAT_USERNAME=root
#MYCAT_PASSWORD=Sunmnet@123
#MYCAT_URL=jdbc:mysql://172.30.254.236:8066/bigdata_web_statis

# mysql服务信息
MYSQL_USERNAME=root
MYSQL_PASSWORD=Sunmnet,hwyff123
MYSQL_URL="jdbc:mysql://172.16.33.153:3306/diagnosis3?useUnicode=true&characterEncoding=utf-8"

# 数据库链接
#MYCAT_CONN="mysql -h 172.30.254.236 -u root -pSunmnet@123 -P8066 bigdata_web_statis -A -N"
MYSQL_CONN="mysql -h 172.16.33.153 -u root Sunmnet,hwyff123 -P3306 diagnosis3 -A -N"

#创建表，存储同步版本信息
CREATETABLE="
	CREATE TABLE IF NOT EXISTS crontab_version (
	  table_name varchar(64)  NOT NULL COMMENT '表名',
	  version int(11) DEFAULT NULL COMMENT '版本',
	  next_version int(11) DEFAULT NULL COMMENT '下个版本',
	  update_cycle int(11) DEFAULT NULL COMMENT '以天为单位',
	  update_time datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
	  PRIMARY KEY (table_name)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8
"
$MYSQL_CONN -e "$CREATETABLE"

#验证当前表数据是否是最新同步
#valid tableName
#数据版本，以当天时间为最新版本
VERSION=`date +"%Y%m%d"`
function valid(){
	SQL="select next_version from crontab_version where table_name='$1'"
	RESULT=`$MYSQL_CONN -e "$SQL"`

	if [ "${RESULT}" = "" -o "${RESULT}" = "NULL" ];then
		echo "true"
	else
		if [ ${VERSION} -ge ${RESULT} ]; then
			echo "true"
		else 
			echo "false"
		fi
	fi
}

#每次同步完成之后调用此方法，更新最新同步版本
#finish tableName
function finish(){
	NEXT_VERSION=`date +"%Y%m%d" -d "+1day"`
	SQL="INSERT INTO crontab_version (table_name, version, next_version, update_cycle) 
		VALUES ('$1', ${VERSION}, ${NEXT_VERSION}, 1) 
		ON DUPLICATE KEY UPDATE 
		version = '${VERSION}',
		next_version = date_format(version + INTERVAL update_cycle DAY,'%Y%m%d')"
	$MYSQL_CONN -e "$SQL"
}

#记录统计脚本运行结束时间
function finish_app(){
	SQL="INSERT INTO crontab_version (table_name, version, next_version, update_cycle, update_time) 
		VALUES ('$1', NULL, NULL, NULL, current_timestamp()) 
		ON DUPLICATE KEY UPDATE 
		update_time = current_timestamp()"
	$MYSQL_CONN -e "$SQL"
}



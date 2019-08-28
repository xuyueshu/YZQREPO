#!/bin/sh
#################################################
###   教务系统数据导入
#################################################

source ../config_raw.sh

# 原始数据源信息
SOURCE_JDBC_URL=jdbc:oracle:thin:@//172.16.10.51:1521/qzorcl
SOURCE_DATABASE=CQCSJWXT
SOURCE_USERNAME=ptjwxtzh
SOURCE_PASSWORD=ptjwxtzh
# 数据库
HIVE_DB=raw

if [ $# == 1 ]
    then
    echo "table:$1"
    tables=($1)
else
    tables=('V_CQCS_XLXX')
fi


for ele in ${tables[*]}
do
	table=${ele}

    # 删除已存在库表
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${table}"

	export HADOOP_OPTS=-Djava.security.egd=file:/dev/../dev/urandom

	sqoop import -D mapred.child.java.opts="-Djava.security.egd=file:/dev/../dev/urandom"
	
    # 导入表结构
	sqoop create-hive-table --connect ${SOURCE_JDBC_URL} --username ${SOURCE_USERNAME} --password ${SOURCE_PASSWORD} \
	--table ${SOURCE_DATABASE}.${table} --hive-table ${HIVE_DB}.${table}	
    # 全量导入数据，列分隔符'\001'，null字符串'\\N'
	sqoop import --hive-import --connect ${SOURCE_JDBC_URL} --username ${SOURCE_USERNAME} --password ${SOURCE_PASSWORD} \
	-m 1 --table ${SOURCE_DATABASE}.${table} --hive-table ${HIVE_DB}.${table} \
	--hive-drop-import-delims --fields-terminated-by '\001'

done

rm -f *.java

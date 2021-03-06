#!/bin/sh
#################################################
###   图书馆管理系统导入
#################################################

source ../config_raw.sh

# 原始数据源信息
SOURCE_JDBC_URL="jdbc:oracle:thin:@//172.16.12.31:1521/GDLISNET"
SOURCE_USERNAME=test
SOURCE_PASSWORD=test
DATABASE=GDLISNET
# 目标数据库
HIVE_DB=raw
HIVE_TABLE=collection_of_store;



# 馆藏典藏库
	hive -e "DROP table ${HIVE_DB}.${HIVE_TABLE};
		CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
			main_id string,
			barcode string
	  );"
	  
	hadoop fs -rm -r -skipTrash /user/hueoperator/raw/collection
	
	export HADOOP_OPTS=-Djava.security.egd=file:/dev/../dev/urandom

	sqoop import -D mapred.child.java.opts="-Djava.security.egd=file:/dev/../dev/urandom"	

# 全量导入数据，列分隔符'\001'，null字符串'\\N'
        sqoop import --verbose --connect ${SOURCE_JDBC_URL} --username ${SOURCE_USERNAME} --password ${SOURCE_PASSWORD} \
        -m 1 --hive-delims-replacement "" \
        --target-dir /user/hueoperator/raw/collection --fields-terminated-by '\001' \
        --query " select 
					主键码,
					条形码
				from GDLISNET.馆藏典藏库 where 1=1 and \$CONDITIONS"
				
#导入数据
hive -e "LOAD DATA INPATH '/user/hueoperator/raw/collection/part-m-00000' OVERWRITE INTO TABLE ${HIVE_DB}.${HIVE_TABLE};"


rm -f *.java

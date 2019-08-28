#!/bin/sh
#################################################
###   图书馆管理系统导入
#################################################

source ../config2.sh

#原始数据源信息
SOURCE_JDBC_URL="jdbc:oracle:thin:@//172.16.12.31:1521/GDLISNET"
SOURCE_USERNAME=test
SOURCE_PASSWORD=test
DATABASE=GDLISNET
# 数据库
HIVE_DB=raw
TABLE=guancangshumuku;

if [ $# == 1 ]
    then
    echo "table:$1"
    tables=($1)
else
    tables=('馆藏书目库')
fi 

#建立馆藏书目库表结构
 hive -e "DROP table ${HIVE_DB}.${TABLE};
 CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${TABLE}(
	  库键码        string,
	  主键码		string, 
	  题名	        string, 
	  题名缩写		string, 
	  语种			string, 
	  版次		    string, 
	  责任者		string, 
	  出版者    	string, 
	  出版地		string, 
	  出版日期		string, 	  	  
	  标准编码      string,
	  索书号		string, 
	  册数	        string, 
	  可外借数		string, 
	  已外借数		string, 
	  预约数 		string, 
	  图象页数 		string, 
	  卷标	        string, 
	  操作员		string,
	  修改人员 		string,
	  处理日期      string,
	  上月外借册数	string, 
	  本月外借册数	string, 
	  去年外借册数	string, 
	  今年外借册数	string, 
	  累计外借册数 	string, 
	  题名2			string, 
	  责任者2	    string, 
	  出版者2		string, 
	  首馆键码		string, 	  	  
	  索书号A       string,
	  创建时间		string, 
	  书目记录号	string, 
	  封面		    string, 
	  价格		    string, 
	  文献类型		string, 
	  责任者一 		string, 
	  责任者二	    string, 
	  任者三		string,
	  责任者四 		string,  
	  分类号     	string,
	  下载		    string, 
	  封面地址	    string, 
	  内容介绍		string, 
	  采编审核		string, 
	  采编审核员 	string, 
	  采编审核日期	string, 
	  编目审核	    string, 
	  编目审核员	string, 
	  编目审核日期	string, 	  	  
	  排架号        string,
	  COVERPATH		string, 
	  SUMMARYS	    string, 
	  丛书名		string, 
	  分类		    string, 
	  种次		    string, 
	  MARC类型 		string, 
	  翻阅次数	    string, 
	  调配时间		string,
	  调配员		string);"

for ele in ${tables[*]}
do
	table=${ele}

    # 删除已存在库表
    #hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${table}"
		

	export HADOOP_OPTS=-Djava.security.egd=file:/dev/../dev/urandom

	sqoop import -D mapred.child.java.opts="-Djava.security.egd=file:/dev/../dev/urandom"
	
   
    # 全量导入数据，列分隔符'\001'，null字符串'\\N'
	sqoop import --hive-import --connect ${SOURCE_JDBC_URL} --username ${SOURCE_USERNAME} --password ${SOURCE_PASSWORD} \
	-m 1 --table ${DATABASE}.${table} --hive-table ${HIVE_DB}.${TABLE}  \
	--map-column-hive ${table}.封面=STRING,${table}.=STRING \
	--hive-drop-import-delims --fields-terminated-by '\001'

done

rm -f *.java

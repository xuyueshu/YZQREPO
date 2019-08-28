#!/bin/sh
#################################################
###  功能说明:原始数据导入
###  导入方式:全量导入
###  导入结果:hive中assurance库
###  运行频率:初始化
###  数据来源:陕西能源职业技术学院
###  运行条件:无,支持数据重跑
###  运行命令:sh im_quality_data_base_info.sh
###  维护人:
###  运行日期：2019-07-09
###  质控点数据项基础信息表
#################################################
source ./config.sh
HIVE_DB=assurance
if [ $# == 1 ]
    then
    echo "table:$1"
    tables=($1)
else
tables=('
im_quality_data_base_info
')
fi

for ele in ${tables[*]}
do
    table=${ele}

    #删除外部文件
    hadoop fs -rm -r "hdfs:/${HIVE_DB}/${table}"
    #删除表结构
    hive -e "USE ${HIVE_DB};DROP TABLE IF EXISTS ${table};"
    #新建表
    sqoop create-hive-table --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
     --table ${table}  --hive-table ${HIVE_DB}.${table}
    #改为外部表
    hive -e "alter table ${HIVE_DB}.${table} set TBLPROPERTIES ('EXTERNAL'='TRUE');"
    #修改外部表路径
    hive -e  "alter table ${HIVE_DB}.${table} set location 'hdfs:/${HIVE_DB}/${table}';"
    #导入数据
    sqoop import --hive-import --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${table} --hive-table ${HIVE_DB}.${table} \
    -m 1 --hive-overwrite \
    --input-null-string '\\N' \
    --input-null-non-string '\\N' \
    --hive-drop-import-delims \
    --null-string '\\N' --null-non-string '\\N' --fields-terminated-by '\0001'
done

rm -rf ./*.java
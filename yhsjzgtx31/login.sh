#!/bin/sh
#################################################
###  功能:通用导入hive数据库
###  导入方式:全量导入
###  数据源:关系型数据库
###  结果:hive中raw库
###  运行条件:无,支持数据重跑
###  运行命令:sh import_table_common.sh [table]
###  维护人:wdong
#################################################
#source /root/script/config.sh

function login(){
    echo "in"
    expect_sh=$(expect -c "
    spawn kinit hdfs
    expect \"*assword*SUNMNET.COM:\"
    send \"sunmnet@123\r\"
    expect \"#\"
    ")

    echo "$expect_sh"
}

login



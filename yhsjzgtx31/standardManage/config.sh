#!/bin/sh
#################################################
###  功能:全局变量定义及function
#################################################

# hive外部表根目录
BASE_HIVE_DIR=/user/hivedb
SHELL_PATH=/root/etl

# MYSQL服务信息
MYSQL_HOST=119.3.74.110
MYSQL_USERNAME=root
MYSQL_PASSWORD=Sunmnet,hwyff123
MYSQL_PORT=3306
MYSQL_DB=standardManage
MYSQL_URL="jdbc:mysql://119.3.74.110:3306/${MYSQL_DB}?characterEncoding=utf-8"

function finish() {
    rm -rf *.java
    fn_log 'finish!'
}

function exec_dir() {
    if [ ! -d "logs" ]; then
      mkdir logs
    fi
    rm -f logs/$@_`date -d "-40 day" +%Y-%m`'*'.log
    exec >> logs/$@_`date +%Y-%m-%d`.log 2>&1
}

function log_info() {
    DATE_N=`date '+%Y年%m月%d日 %T'`
    USER_N=`whoami`
    echo -e "\033[32m[${DATE_N}] [${USER_N}] execute [$0] [INFO] $@  \033[0m"
}

function log_error(){
    DATE_N=`date '+%Y年%m月%d日 %T'`
    USER_N=`whoami`
    echo -e "\033[41;37m[${DATE_N}] [${USER_N}] execute [$0] [ERROR] $@ \033[0m"
    echo -e "\033[41;37m[${DATE_N}] [${USER_N}] execute [$0] [ERROR] $@ \033[0m" >> ${SHELL_PATH}/err_log/err_`date +%Y-%m-%d`.log
}

function fn_log()  {
    if [  $? -eq 0  ]
    then
        log_info "$@ successful."
    else
        log_error "$@ failed."
    fi
}

function cur_se_year_by_date(){
    echo `hive -e "SELECT semester_year FROM model.semester_info WHERE from_unixtime(unix_timestamp(),'yyyy-MM-dd') BETWEEN begin_time and end_time"`
}

function cur_sem_by_date(){
    echo `hive -e "SELECT semester FROM model.semester_info WHERE from_unixtime(unix_timestamp(),'yyyy-MM-dd') BETWEEN begin_time and end_time"`
}

function cur_se_year_by_sort(){
    echo `hive -e "SELECT semester_year FROM model.semester_info WHERE sort = 1"`
}

function last_year(){
  se_year=$1
  last_year=$[${se_year:0:4}-1]"-"${se_year:0:4}
  echo "${last_year}"
}

function cur_sem_by_sort(){
    echo `hive -e "SELECT semester FROM model.semester_info WHERE sort = 1"`
}

function clear_mysql_data() {
	mysql -h ${MYSQL_HOST} -u ${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -P${MYSQL_PORT} -e "USE ${MYSQL_DB};${1}"
}


INIT=''
if [  $# == 1 ]
    then
    if [  $1x == "init"x  ]
        then
        INIT=$1
    fi
fi

function init_exit(){
    if [ ${INIT}x == 'init'x ]
        then
        create_table
        finish
        exit
    fi
}
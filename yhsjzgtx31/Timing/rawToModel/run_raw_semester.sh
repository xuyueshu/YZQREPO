#!/bin/sh
cd `dirname $0`
#################################################
#raw库学期执行的统一执行脚本
#################################################

#日志路径
function getRunLogPath(){
    datetime=$(date --date "0 days ago" +%Y%m%d)
    if [ ! -d "./logs" ];then
        mkdir ./logs
    fi
    LOG_RUN_PATH=/root/etl/SXNYZY/Timing/logs/$0_${datetime}.log
}

#数据抽取
function import_raw_table() {

        #脚本开始执行时间
        start=$(date +%s)
        for ele in ${tables[*]}
        do
            table=${ele}

            #删除外部文件
            hadoop fs -rm -r "hdfs:/${HIVE_DB}/${TABLE_PREFIX}${table}"
            #删除表结构
            hive -e "USE ${HIVE_DB};DROP TABLE IF EXISTS ${TABLE_PREFIX}${table};"
            #新建表
            sqoop create-hive-table --connect jdbc:oracle:thin:@172.16.98.27:1521/KFPTDB --username usr_zg --password sxny@123 \
             --table USR_ZSJ.${table}  --hive-table ${HIVE_DB}.${TABLE_PREFIX}${table}
            #改为外部表
            hive -e "alter table ${HIVE_DB}.${TABLE_PREFIX}${table} set TBLPROPERTIES ('EXTERNAL'='TRUE');"
            #修改外部表路径
            hive -e  "alter table ${HIVE_DB}.${TABLE_PREFIX}${table} set location 'hdfs:/${HIVE_DB}/${TABLE_PREFIX}${table}';"
            #导入数据
            sqoop import --hive-import --connect jdbc:oracle:thin:@172.16.98.27:1521/KFPTDB --username usr_zg --password sxny@123 \
            --table USR_ZSJ.${table} --hive-table ${HIVE_DB}.${TABLE_PREFIX}${table} \
            -m 1 --hive-overwrite \
            --input-null-string '\\N' \
            --input-null-non-string '\\N' \
            --hive-drop-import-delims \
            --null-string '\\N' --null-non-string '\\N' --fields-terminated-by '\0001'
            end=$(date +%s)
            echo " $table succeed>>>  耗时$(( $end - $start ))s " >>  ${LOG_RUN_PATH} 2>&1
        done

}
#ec_
function raw_ec_import() {

    getRunLogPath
    TABLE_PREFIX='ec_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_zg_xqhzkfkcxx

    ')
    import_raw_table
}

#ic_
function raw_ic_import() {

    getRunLogPath
    TABLE_PREFIX='ic_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_zg_gjhzxx
t_zg_gjhzjlyhdqk

    ')
    import_raw_table
}

#pm_
function raw_pm_import() {
    getRunLogPath
    TABLE_PREFIX='pm_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_jzg_kyzz
    ')
    import_raw_table
}


#sw_
function raw_sw_import() {
    getRunLogPath
    TABLE_PREFIX='sw_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
T_ZG_KCXXB
T_ZG_XSCJXX
t_bzks
T_ZG_XG_QGZX
T_ZG_XG_XSPJJG
T_ZG_XSZS
    ')
    import_raw_table
}
#te_
function raw_te_import() {
    getRunLogPath
    TABLE_PREFIX='te_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
achievement_test
oc
course
achievement_online_forum_qa
class_student
oc_forum
resources
teacher
T_ZG_XQHZKFKCXX
t_zg_zyjxzyk
    ')
    import_raw_table
}
#zgy_
function raw_zgy_import() {
    getRunLogPath
    TABLE_PREFIX='zgy_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
T_ZG_ZYXX
t_zg_jw_xl
T_ZG_JSKB
T_ZG_KCKTPJXX
T_ZG_KCXXB
T_ZG_JSKBXX
t_zg_kcktpjxx
T_ZG_KCSXJXXXB
T_ZG_SXXMXXB
t_zg_jstdkxx
    ')
    import_raw_table
}


HIVE_DB=raw
getRunLogPath
if [ $# == 1 ] ; then
    echo "table:$1,参数！"
else
        raw_ec_import
        raw_te_import
        raw_ic_import
        raw_pm_import
         raw_sw_import
         raw_zgy_import

fi
rm -rf *.java





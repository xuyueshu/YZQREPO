#!/bin/sh
cd `dirname $0`
#################################################
#raw库每学年执行的统一执行脚本
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
T_ZG_XQHZPYXSXX
    ')
    import_raw_table
}
#hr_
function raw_hr_import() {

    getRunLogPath
    TABLE_PREFIX='hr_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_jzg
t_jzg_jzcjl
    ')
    import_raw_table
}

#oe_
function raw_oe_import() {
    getRunLogPath
    TABLE_PREFIX='oe_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
T_ZG_XSBYXX
T_JY_BYQX

    ')
    import_raw_table
}
#pm_
function raw_pm_import() {
    getRunLogPath
    TABLE_PREFIX='pm_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_jzg_zwjl
t_jzg_hjxx
t_xx_dw
t_jzg_pxxx
T_ZG_JSZYGS
    ')
    import_raw_table
}
#rs_
function raw_rs_import() {
    getRunLogPath
    TABLE_PREFIX='rs_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_zg_hzqyxx
t_zg_qyjzsbxx
t_zg_zsjhb
T_ZG_ZSJHB
t_zg_ksxx
    ')
    import_raw_table
}

#sr_
function raw_sr_import() {
    getRunLogPath
    TABLE_PREFIX='sr_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_ky_kyxmx
T_KY_KYDKQK
t_ky_zlxx
t_ky_zlryxx
T_KY_HJXX
T_KY_HJRYXX
T_KY_FBLWXX
T_KY_LWRYXX
T_KY_KYXMXX
T_KY_ZZRYXX
    ')
    import_raw_table
}
#ss_
function raw_ss_import() {
    getRunLogPath
    TABLE_PREFIX='ss_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_zg_lfjlxx
t_zg_mtbdqkb
t_zg_shpxxx
    ')
    import_raw_table
}
#sw_
function raw_sw_import() {
    getRunLogPath
    TABLE_PREFIX='sw_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
T_ZG_XG_ZZXX
    ')
    import_raw_table
}
#te_
function raw_te_import() {
    getRunLogPath
    TABLE_PREFIX='te_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_bzks_bjap
t_jzg_ndkh
t_bzks_bjap
    ')
    import_raw_table
}
#zgy_
function raw_zgy_import() {
    getRunLogPath
    TABLE_PREFIX='zgy_'
    echo "===${TABLE_PREFIX} 开始执行==="
    tables=('
t_zg_tszc
t_zg_zyxx
T_ZG_SXJDSXSGLXXB
T_ZG_SXYQSBXX
T_ZG_XNXWSXJDXX
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
        raw_hr_import
        raw_oe_import
        raw_pm_import
        raw_rs_import
        raw_sr_import
        raw_ss_import
        raw_sw_import
        raw_zgy_import

fi
rm -rf *.java





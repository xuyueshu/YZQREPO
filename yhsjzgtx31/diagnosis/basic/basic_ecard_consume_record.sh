#!/bin/sh
#################################################
###  基础表:       一卡通消费流水信息表
###  维护人:       王浩
###  数据源:

###  导入方式:      增量导入
###  运行命令:      sh model_ecard_consume_record.sh
###  结果目标:      model.ecard_consume_record
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_consume_record


HIVE_DB=model
HIVE_TABLE=basic_consume_record

function create_table(){
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

    hive -e "
        CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            code STRING COMMENT '学号,教工号',
            semester_year STRING COMMENT '学年',
            semester STRING COMMENT '学期',
            record_time STRING COMMENT '消费时间 格式yyyy-MM-dd hh:mm:ss',
            fee decimal(10,2) COMMENT '费用，单位：元',
            store_code STRING COMMENT '商户编号',
            store_name STRING COMMENT '商户名称',
            store_type STRING COMMENT '商户类型 0餐饮,1超市,2洗浴,3洗衣,4取水,5网络,6体育运动,7医疗,99其他'
        )
        COMMENT '一卡通消费流水信息表'
        partitioned by(semester_year string,semester string)
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建表--一卡通消费流水信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

    fn_log "${1}-------${2}"

    hive -e "ALTER TABLE ${HIVE_DB}.${HIVE_TABLE} DROP IF EXISTS PARTITION(semester_year='${1}',semester='${2}')"

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}/semester_year=${1}/semester=${2}/ || :

    fn_log "删除分区原有数据:${1}${2}"

    #   样例

#    hive -e "
#        SET hive.exec.dynamic.partition=true;
#        SET hive.exec.dynamic.partition.mode=nonstrict;
#        SET hive.exec.max.dynamic.partitions.pernode=1000;
#        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE} partition(semester_year,semester)
#        SELECT
#            trim(c.outid) as code,
#            substr(c.opdt,0,19) as record_time,
#            cast(c.opfare as DECIMAL)/100 as fee,
#            c.acccode as store_code,
#            si.semester_year,
#            si.semester
#        FROM
#            raw_ecard.m_rec_consume c
#            LEFT JOIN model.semester_info si
#        WHERE
#            substr(c.opdt,0,19) BETWEEN si.begin_time and si.end_time
#    "

    fn_log "导入数据--一卡通消费流水信息表:${HIVE_DB}.${HIVE_TABLE}"
}


init_exit
import_table `cur_se_year_by_sort` `cur_sem_by_sort`
finish




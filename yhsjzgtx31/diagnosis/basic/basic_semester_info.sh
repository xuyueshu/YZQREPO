#!/bin/sh
#################################################
###  基础表:       学期基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量
###  运行命令:      sh basic_semester_info.sh. &
###  结果目标:      model.basic_semester_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_semester_info

HIVE_DB=model
HIVE_TABLE=basic_semester_info
TARGET_TABLE=basic_semester_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            semester_year STRING COMMENT '学年',
            semester STRING COMMENT '学期',
            begin_time STRING COMMENT '开始时间',
            end_time STRING COMMENT '结束时间',
            sort STRING COMMENT '排序,开始时间倒序排列'
      )COMMENT '学期基础信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--学期基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
      hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
       select
        a.semester_year,
        a.semester,
        concat(a.begin_time,' ','00:00:00') as begin_time,
        concat(a.end_time,' ','23:59:59') as end_time,
        row_number() over(order by end_time desc) as sort
        from
        (
        select
        xn as semester_year ,
        xnxq as semester,
        min(kssj) begin_time,
        max(jssj) end_time
        from raw.v_cqcs_xlxx
        group by xn,xnxq
        ) a
        "
    fn_log "导入数据--学期基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "semester_year,semester,begin_time,end_time,sort"

    fn_log "导出数据--学期基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish
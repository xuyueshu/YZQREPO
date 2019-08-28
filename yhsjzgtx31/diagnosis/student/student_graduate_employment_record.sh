#!/bin/sh
###################################################
###   基础表:      毕业生名单信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_graduate_employment_record

HIVE_DB=model
HIVE_TABLE=student_graduate_employment_record
TARGET_TABLE=student_graduate_employment_record
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=$((${PRE_YEAR} - 2))"-"$((${PRE_YEAR} - 1))
function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              code      STRING    COMMENT '学生编号',
              name      STRING    COMMENT '学生姓名',
              birthdate      STRING    COMMENT '出生日期',
              sex      STRING    COMMENT '性别',
              politics_status      STRING    COMMENT '政治面貌',
              identity_card      STRING    COMMENT '身份证号',
              birthplace      STRING    COMMENT '生源地'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "毕业生名单信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}

#出生日期/性别/政治面貌/身份证号/生源地
function import_table(){
        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             distinct
             a.xh  as code,
             a.xm  as name,
             b.CSRQ as birthdate,
             b.xbdm as sex,
             case when b.zzmmdm is null  then 13 else  b.zzmmdm end as  politics_status,
             b.sfzjh as identity_card,
             b.syddm as birthplace
             from raw.oe_T_ZG_XSBYXX a
             left join raw.sw_t_bzks b on a.XH=b.xh
             where a.sfby = '是'
        "
        fn_log " 导入数据--毕业生名单信息表:${HIVE_DB}.${HIVE_TABLE}"

}


init_exit
create_table
import_table
finish
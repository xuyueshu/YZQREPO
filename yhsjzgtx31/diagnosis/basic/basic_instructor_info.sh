#!/bin/sh
#################################################
###  基础表:       辅导员信息表
###  维护人:       王浩
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_instructor_info.sh. &
###  结果目标:      app.basic_instructor_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_instructor_info

HIVE_DB=model
HIVE_TABLE=basic_instructor_info
TARGET_TABLE=basic_instructor_info
PRE_YEAR=`date +%Y`
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            teacher_code STRING COMMENT '教师编号',
            instructor_type STRING COMMENT '辅导员类型：academy院系辅导员，major专业辅导员，class班级辅导员',
            code STRING COMMENT '编号：院系专业或班级编号',
            grade STRING COMMENT '年级'
      )COMMENT '辅导员信息表'
    PARTITIONED BY(year STRING COMMENT '统计学年')
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--辅导员信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
 hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE} partition ( year = '${NOW_YEAR}')
        select
        distinct
        nvl(a.ZGH,' ') as teacher_code,
        case when a.BMMC like '%学院%' or a.BMMC='学生处' then 'academy'
        when a.BMMC is null then ' ' end  as instructor_type,
        nvl(a.BMDM,' ') as code,
        '${NOW_YEAR}' as grade
        from
        raw.sw_T_ZG_XG_FDYXXB a
    "
    fn_log "导入数据--辅导员信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "delete from ${TARGET_TABLE} where grade='${NOW_YEAR}' ;"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}/year=${NOW_YEAR} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "teacher_code,instructor_type,code,grade"

    fn_log "导出数据--辅导员信息表:${HIVE_DB}.${TARGET_TABLE}"
}
#function export_table(){
#
#    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#
#    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
#    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
#    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
#    --null-string '\\N' --null-non-string '\\N' \
#    --columns "teacher_code,instructor_type,code,grade"
#
#    fn_log "导出数据--专业基础信息表:${HIVE_DB}.${TARGET_TABLE}"
#}
function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
    years=3
    for((i=1;i<=3;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
      export_table
    done
}

#第一次执行create_table / getYearData / export_table:TRUNCATE``  循环近5年的
#第二次执行create_table / import_table / export_table : delete``` where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
#import_table
finish
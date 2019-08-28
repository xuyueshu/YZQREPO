#!/bin/sh
###################################################
###   基础表:      学生助学金明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_grant_detailed

HIVE_DB=model
HIVE_TABLE=student_grant_detailed
TARGET_TABLE=student_grant_detailed
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                  code      STRING    COMMENT '学生编号',
                  semester_year      STRING    COMMENT '学年',
                  grant_money      STRING    COMMENT '助学金金额',
                  grant_grade      STRING    COMMENT '助学金等级(参照枚举表ZXJDJ中code值)',
                  grant_time      STRING    COMMENT '获奖日期(yyyy-mm-dd)',
                  name      STRING    COMMENT '助学金名称',
                  subsidized_unit      STRING    COMMENT '资助单位'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生助学金明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}
#GJYDZXJ', '国家一等助学金
#GJEDZXJ', '国家二等助学金
#GJSDZXJ', '国家三等助学金
#'SJYDZXJ', '省级一等助学金'
#'SJEDZXJ', '省级二等助学金'
#'SJSDZXJ', '省级三等助学金'
#获奖日期  资助单位
#数据没有省级相关的数据，基本上是有关校级的助学金数据，枚举中没有相关学校级别的code
#第一次into 以后overwrite
function import_table(){

        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             a.XH as code,
             a.XN as semester_year,
             nvl(a.JE,' ')  as grant_money,
             nvl(case when a.XMMC='国家助学金(一般贫困)' then 'GJSDZXJ'
                  when a.XMMC='国家助学金(建档立卡)' then 'GJEDZXJ'
                  when a.XMMC='国家助学金(特困)' then 'GJYDZXJ' end,' ') as grant_grade,
             ' ' as grant_time ,
             a.XMMC as name,
             ' ' as subsidized_unit
             from
             raw.sw_T_ZG_XG_ZZXX a
             where a.SFZX='在校' and a.SFYBY='否'
             and a.XN='${semester}'
             and a.XMMC like '%助学金%'

        "
        fn_log " 导入数据--学生助学金明细表:${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

        clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#        clear_mysql_data "delete from ${TARGET_TABLE} where semester_year='${semester}' ;"

        sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
        --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
        --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
        --null-string '\\N' --null-non-string '\\N'  \
        --columns "code,semester_year,grant_money,grant_grade,grant_time,name,subsidized_unit"

        fn_log "导出数据--学生助学金明细表:${HIVE_DB}.${TARGET_TABLE}"

}
function getYearData(){
    vDate=`date +%Y`
    let vDate+=1;
    years=5
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
    done
}

#第一次执行create_table / getYearData / export_table:TRUNCATE``  循环近5年的
#第二次执行create_table / import_table / export_table : delete``` where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
#import_table
export_table
finish
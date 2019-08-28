#!/bin/sh
###################################################
###   基础表:      学生奖学金统计表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_scholarship_record

HIVE_DB=model
HIVE_TABLE=student_scholarship_record
TARGET_TABLE=student_scholarship_record

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              scholarship_name      STRING    COMMENT '奖学金名称',
              scholarship_type      STRING    COMMENT '奖学金类型（1:学院奖学金，2:国家奖学金，3:特殊及其他）',
              scholarship_level      STRING    COMMENT '奖学金等级，参照enum_info中XYJXJ,GJJXJ,QYJXJ类型，保存对应code 1:一等/国家/特殊，2二等/省/其他 3，三等/市',
              amount      STRING    COMMENT '金额',
              code      STRING    COMMENT '学生编号',
              time      STRING    COMMENT '评定时间',
              scholarship_code      STRING    COMMENT '奖学金编号',
              subsidized_unit      STRING    COMMENT '资助单位/个人',
              semester_year      STRING    COMMENT '学年'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生奖学金统计表--'${HIVE_DB}.${HIVE_TABLE}'"
}
#资助单位
#第一次into 以后overwrite
function import_table(){

        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             nvl(a.XMMC,' ') as scholarship_name,
             nvl(case when a.XMMC like '%学校%' then 1 end ,' ') as scholarship_type,
             nvl(case when a.XMMC='学校(一等奖学金)' then 1
                  when a.XMMC='学校(二等奖学金)' then 2
                  when a.XMMC='学校(三等奖学金)' then 3 end ,' ') as scholarship_level,
              nvl(a.JE,' ') as amount,
              nvl(a.XH,' ') as code,
              a.SQSJ as time,
              a.LBDM as subsidized_unit,
              ' ' as subsidized_unit,
              a.XN as semester_year
             from raw.sw_T_ZG_XG_ZZXX a
             where a.XN='${semester}'
             and
             a.SFZX='在校' and a.SFYBY='否'
             and a.XMMC like '%奖学金%'

        "
        fn_log " 导入数据--学生奖学金统计表:${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#    clear_mysql_data "delete from ${TARGET_TABLE} where semester_year='${semester}';"


    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "scholarship_name,scholarship_type,scholarship_level,amount,code,time,scholarship_code,subsidized_unit,semester_year"

    fn_log "导出数据--学生奖学金统计表:${HIVE_DB}.${TARGET_TABLE}"

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
#create_table
#getYearData
#import_table
export_table
finish
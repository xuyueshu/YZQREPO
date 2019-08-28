#!/bin/sh
###################################################
###   基础表:      学生体能测试明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_physical_test_record

HIVE_DB=model
HIVE_TABLE=student_physical_test_record
TARGET_TABLE=student_physical_test_record
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              code      STRING    COMMENT '学生编号',
              semester_year      STRING    COMMENT '学年',
              semester      STRING    COMMENT '学期',
              score      STRING    COMMENT '成绩',
              ranking      STRING    COMMENT '排名',
              is_qualified      STRING    COMMENT '是否合格（1合格 2不合格）'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生体能测试明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}
#排名 ?指的是班级排名还是专业排名还是院系排名
#第一次into 第二次overwrite
function import_table(){

        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             a.XH as code,
             a.XN as semester_year,
             substr(a.XQ,2,1) as semester,
             a.TCDF as score,
             ' ' as ranking,
             case when a.TCDF>=60 then 1 else 2 end as is_qualified
             from
             raw.sw_t_zg_stxlsz a
             where a.XN='${semester}'

        "
        fn_log " 导入数据--学生体能测试明细表:${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
    # clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year='${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,semester_year,semester,score,ranking,is_qualified"

    fn_log "导出数据--学生体能测试明细表:${HIVE_DB}.${TARGET_TABLE}"

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

#第一次执行create_table / getYearData /export_table:truncate table··· 循环近5年的
#第二次执行第一次执行create_table/import_table/export_table：delete from··· where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
#import_table
export_table
finish

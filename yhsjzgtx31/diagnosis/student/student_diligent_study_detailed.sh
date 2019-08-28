#!/bin/sh
###################################################
###   基础表:      学生勤工助学明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_diligent_study_detailed.sh &
###  结果目标:      model.student_diligent_study_detailed
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_diligent_study_detailed

HIVE_DB=model
HIVE_TABLE=student_diligent_study_detailed
TARGET_TABLE=student_diligent_study_detailed
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '学生编号',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        address   STRING     COMMENT '勤工助学地点',
                                        length_time   STRING     COMMENT '时长(天)',
                                        start_time   STRING     COMMENT '勤工助学开始时间(格式2018-01-01)',
                                        end_time   STRING     COMMENT '勤工助学结束时间(格式2018-02-01)',
                                        company_name   STRING     COMMENT '用人单位名称',
                                        issue_date   STRING     COMMENT '发放日期(yyyy-mm-dd)',
                                        money   STRING     COMMENT '勤工助学金额',
                                        company_type   STRING     COMMENT '助学单位类别(校外/院系/部处/后
勤)'        )COMMENT  '学生勤工助学明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生勤工助学明细表: ${HIVE_DB}.${HIVE_TABLE}"
}
#第一次into 以后改成overwrite
function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        select
         a.xh as code,
         a.xn as semester_name,
         1 as semester,
         '陕西能源职业技术学院' as address,
         a.gs as length_time,
         a.gwkssj as start_time,
         a.GWJSSJ as end_time,
         a.YRDWMC as company_name,
         a.FFXN as issue_date,
         a.JE as money,
         case when a.YRDWMC like '%处%' then '部处' end as company_type
        from
        raw.sw_T_ZG_XG_QGZX a
        where a.XN='${semester}'

        "
        fn_log " 导入数据--学生勤工助学明细表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#    clear_mysql_data "delete from ${TARGET_TABLE} where semester_name='${SEERMEST_YEARS}' ;"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,semester_year,semester,address,length_time,start_time,end_time,company_name,issue_date,money,company_type"

    fn_log "导出数据--学生勤工助学明细表: ${HIVE_DB}.${TARGET_TABLE}"

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

#第一次执行create_table / getYearData / export_table 循环近5年的 export_table:truncate table  ```
#第二次执行create_table / import_table / export_table  export_table: delete from ``` where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
#import_table
export_table
finish

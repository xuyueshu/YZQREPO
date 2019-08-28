#!/bin/sh
###################################################
###   基础表:      获奖成果数据
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_award_result_info.sh &
###  结果目标:      model.scientific_award_result_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir scientific_award_result_info

HIVE_DB=model
HIVE_TABLE=scientific_award_result_info
TARGET_TABLE=scientific_award_result_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '获奖编号',
                                        name   STRING     COMMENT '获奖名称',
                                        result_name   STRING     COMMENT '成果名称',
                                        unit_name   STRING     COMMENT '所属单位',
                                        level   STRING     COMMENT '获奖级别(国家级，省部级，市级科)',
                                        award_level   STRING     COMMENT '获奖等级',
                                        award_date   STRING     COMMENT '获奖日期',
                                        award_approval_number   STRING     COMMENT '奖励批准号',
                                        award_categories   STRING     COMMENT '奖励类别',
                                        first_author   STRING     COMMENT '第一作者',
                                        first_author_code   STRING     COMMENT '第一作者编号',
                                        first_author_type   STRING     COMMENT '第一作者类型',
                                        semester_year   STRING     COMMENT '学年',
                                        remarks   STRING     COMMENT '备注'        )COMMENT  '获奖成果数据'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--获奖成果数据: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        select
       b.code,
       b.name,
       b.result_name,
       b.unit_name,
       b.level,
       b.award_level,
       b.award_date,
       b.award_approval_number,
       b.award_categories,
        b.first_author,
        b.first_author_code,
        b.first_author_type,
       b.semester_year,
        b.remarks
        from
        (
          select
			a.AWARD_NO as	code,
           a.AWARD_NAME as name,
           a.AWARD_NAME as result_name,
           b.DEPARTMENT as unit_name,
           a.AWARD_RANK as level,
           a.AWARD_GRADE as award_level,
           cast(concat(substr(a.AWARD_DATE,1,4),'-',substr(a.AWARD_DATE,5,2),'-',substr(a.AWARD_DATE,7,2)) as date) as award_date,
           '' as award_approval_number,
           a.AWARD_TYPE as award_categories,
           b.PRIZEWINNER_NAME  first_author,
           b.PRIZEWINNER_NO as  first_author_code,
           b.ROLE_TYPE as first_author_type,
            case
           when substr(a.AWARD_DATE,5,1)=0 and substr(a.AWARD_DATE,6,1)<7 then concat(cast(substr(a.AWARD_DATE,1,4)-1 as int),'-',substr(a.AWARD_DATE,1,4))
            when substr(a.AWARD_DATE,5,1)=0 and substr(a.AWARD_DATE,6,1)>7 then concat(substr(a.AWARD_DATE,1,4),'-',cast(substr(a.AWARD_DATE,1,4)+1 as int))
           when substr(a.AWARD_DATE,5,1)!=0 and substr(a.AWARD_DATE,5,2)>7 then concat(substr(a.AWARD_DATE,1,4),'-',cast(substr(a.AWARD_DATE,1,4)+1 as int))
           end as semester_year,
          ' ' as remarks
			from
			raw.sr_T_KY_HJXX a
			left join
			raw.sr_T_KY_HJRYXX b
			on
			a.AWARD_NO=b.AWARD_CODE
        ) b
        where b.semester_year='${semester}'
        "
        fn_log " 导入数据--获奖成果数据: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#    clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year='${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,result_name,unit_name,level,award_level,award_date,award_approval_number,award_categories,first_author,first_author_code,first_author_type,semester_year,remarks"

    fn_log "导出数据--获奖成果数据: ${HIVE_DB}.${TARGET_TABLE}"

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

#第一次执行create_table / getYearData  循环近5年的 export_table:TRUNCATE TABLE````
#第二次执行create_table / import_table / export_table  where后的变量改成 '${SEMESTER_YEARS}'  export_table:delete from ```
init_exit
create_table
getYearData
#create_table
#import_table
export_table
finish



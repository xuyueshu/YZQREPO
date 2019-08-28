#!/bin/sh
###################################################
###   基础表:      科研著作基本明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_work_basic_info.sh &
###  结果目标:      model.scientific_work_basic_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir scientific_work_basic_info

HIVE_DB=model
HIVE_TABLE=scientific_work_basic_info
TARGET_TABLE=scientific_work_basic_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '著作编号',
                                        project_code   STRING     COMMENT '所属项目编号',
                                        chinese_name   STRING     COMMENT '著作中文名称',
                                        english_name   STRING     COMMENT '著作英文名称',
                                        subordinate_unit   STRING     COMMENT '所属单位',
                                        work_type   STRING     COMMENT '著作类别',
                                        source_unit   STRING     COMMENT '项目来源',
                                        first_author_name   STRING     COMMENT '第一作者姓名',
                                        first_author_type   STRING     COMMENT '第一作者类型',
                                        first_author_code   STRING     COMMENT '第一作者编号',
                                        semester_year   STRING     COMMENT '学年',
                                        publication_date  STRING   COMMENT '出版日期',
                                        level STRING   COMMENT '级别'
                                        )COMMENT  '科研著作基本明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--科研著作基本明细表: ${HIVE_DB}.${HIVE_TABLE}"
}
#所属项目编号 著作英文名称 所属单位  著作类别 项目来源 学年 第一作者类型
#自诊报告里面需要【出版日期/级别】这个字段，抽取的时候只抽到hive里，这个和北京同事已经商讨
function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        select
        a.BOOK_CODE as code,
        '' as project_code,
        a.BOOK_ID as chinese_name,
        '' as english_name,
        '' as subordinate_unit,
        '' as work_type,
        '' as source_unit,
        a.AUTHOR_NAME as first_author_name,
        '' as first_author_type,
        a.AUTHOR_CODE as first_author_code,
        '${semester}' as semester_year,
          '' as  publication_date,
          '' as level
        from
        raw.sr_T_KY_ZZRYXX a

        "
        fn_log " 导入数据--科研著作基本明细表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year='${semester}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,project_code,chinese_name,english_name,subordinate_unit,work_type,source_unit,first_author_name,first_author_type,first_author_code,semester_year"

    fn_log "导出数据--科研著作基本明细表: ${HIVE_DB}.${TARGET_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    let vDate+=1;
    years=3
    for((i=1;i<=3;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      create_table
        import_table
        export_table
    done
}
#init_exit
#create_table
#import_table
#export_table
getYearData
finish
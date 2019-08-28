#!/bin/sh
###################################################
###   基础表:      科研论文基本明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_paper_basic_info.sh &
###  结果目标:      model.scientific_paper_basic_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir scientific_paper_basic_info

HIVE_DB=model
HIVE_TABLE=scientific_paper_basic_info
TARGET_TABLE=scientific_paper_basic_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '论文编号',
                                        subordinate_unit_code   STRING     COMMENT '所属单位代码',
                                        chinese_name   STRING     COMMENT '论文中文名称',
                                        english_name   STRING     COMMENT '论文英文名称',
                                        publication_time   STRING     COMMENT '发表时间',
                                        paper_type   STRING     COMMENT '论文类型',
                                        school_signature   STRING     COMMENT '学校署名',
                                        first_author_name   STRING     COMMENT '第一作者姓名',
                                        first_author_type   STRING     COMMENT '第一作者类型',
                                        first_author_code   STRING     COMMENT '第一作者编号',
                                        item_code   STRING     COMMENT '所属项目编号',
                                        semester_year   STRING     COMMENT '学年',
                                        grade_type   STRING     COMMENT '论文等级类型（ei，sci,中文核心期刊，普通期刊）'        )COMMENT  '科研论文基本明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--科研论文基本明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        select
								b.code,
								b.subordinate_unit_code,
								b.chinese_name,
								b.english_name,
								b.publication_time,
								b.paper_type,
								b.school_signature,
								b.first_author_name,
								b.first_author_type,
								b.first_author_code,
								b.item_code,
								b.semester_year,
								b.grade_type
								from
								(
									select
									a.PAPER_CODE as	code,
                                    ' ' as  subordinate_unit_code,
                                    a.PAPER_NAME_CH as  chinese_name,
                                    a.PAPER_NAME_EN as  english_name,
                                    a.PUBLISH_DATE as    publication_time,
                                    a.RELEASE_TYPE as    paper_type,
                                    '陕西能源职业技术学院' as school_signature,
                                    b.AUTHOR_NAME as  first_author_name,
                                    '' as  first_author_type,
                                    a.FIRST_AUTHOR_CODE as   first_author_code,
                                    ' ' as item_code,
                                   case
								   when substr(a.PUBLISH_DATE,5,1)=0 and substr(a.PUBLISH_DATE,6,1)<7 then concat(cast(substr(a.PUBLISH_DATE,1,4)-1 as int),'-',substr(a.PUBLISH_DATE,1,4))
								    when substr(a.PUBLISH_DATE,5,1)=0 and substr(a.PUBLISH_DATE,6,1)>7 then concat(substr(a.PUBLISH_DATE,1,4),'-',cast(substr(a.PUBLISH_DATE,1,4)+1 as int))
								   when substr(a.PUBLISH_DATE,5,1)!=0 and substr(a.PUBLISH_DATE,5,2)>7 then concat(substr(a.PUBLISH_DATE,1,4),'-',cast(substr(a.PUBLISH_DATE,1,4)+1 as int))
								   end as semester_year,
                                   ' ' as grade_type
								from
								raw.sr_T_KY_FBLWXX a left join raw.sr_T_KY_LWRYXX b
								on a.PAPER_CODE=b.PAPER_CODE and a.FIRST_AUTHOR_CODE=b.AUTHOR_CODE
								)b where b.semester_year is not null
								and  b.semester_year='${semester}'
        "
        fn_log " 导入数据--科研论文基本明细表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#    clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year='${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,subordinate_unit_code,chinese_name,english_name,publication_time,paper_type,school_signature,first_author_name,first_author_type,first_author_code,item_code,semester_year,grade_type"

    fn_log "导出数据--科研论文基本明细表: ${HIVE_DB}.${TARGET_TABLE}"

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

#第一次执行 create_table / getYearData / export_table 循环近5年的 export_table:TRUNCATE TABLE ${TARGET_TABLE};
#第二次执行 import_table / export_table where后的变量改成 '${SEMESTER_YEARS}'  export_table:delete
#
init_exit
#create_table
#getYearData
create_table
import_table
export_table
finish
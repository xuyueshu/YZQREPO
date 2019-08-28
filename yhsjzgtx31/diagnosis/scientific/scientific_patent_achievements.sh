#!/bin/sh
#################################################
###  基础表:       科研专利成果信息明细表
###  维护人:       guojianing
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_patent_achievements.sh. &
###  结果目标:      model.scientific_patent_achievements
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir scientific_patent_achievements

HIVE_DB=model
HIVE_TABLE=scientific_patent_achievements
TARGET_TABLE=scientific_patent_achievements
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	             patent_code STRING COMMENT '专利编号',
                patent_name STRING COMMENT '专利名称',
                subordinate STRING COMMENT '所属单位（系）',
                patent_type STRING COMMENT '专利类型（码）',
                patent_range STRING COMMENT '专利范围',
                 patent_state STRING COMMENT '专利状态',
                semester_year STRING COMMENT '学年',
                first_author_name STRING COMMENT '第一作者姓名',
                first_author_type STRING COMMENT '第一作者类型',
                 first_author_code STRING COMMENT '第一作者编号',
                patent_num STRING COMMENT '专利号'
      )COMMENT '科研专利成果信息明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--科研专利成果信息明细表:${HIVE_DB}.${HIVE_TABLE}"
}
#专利范围 专利状态
function import_table(){
    hive -e "
        INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
        b.patent_code,
        b.patent_name,
        b.subordinate,
        b.patent_type,
        b.patent_range,
        b.patent_state,
        b.semester_year,
        b.first_author_name,
        b.first_author_type,
        b.first_author_code,
        b.patent_code as patent_num
        from
        (
        select
         c.PATENT_CODE as patent_code,
         d.PATENT_NAME as patent_name,
         c.DEPARTMENT as  subordinate,
         d.PATENT_TYPE_CODE as patent_type,
         '' as patent_range,
         '' as patent_state,
         case
            when substr(d.APPLY_DATE,5,1)=0 and substr(d.APPLY_DATE,6,1)<7 then concat(cast(substr(d.APPLY_DATE,1,4)-1 as int),'-',substr(d.APPLY_DATE,1,4))
            when substr(d.APPLY_DATE,5,1)!=0 and substr(d.APPLY_DATE,5,2)>7 then concat(substr(d.APPLY_DATE,1,4),'-',cast(substr(d.APPLY_DATE,1,4)+1 as int))
            when substr(d.APPLY_DATE,5,1)='-' and substr(d.APPLY_DATE,6,1)=0 and substr(d.APPLY_DATE,7,1)<7
            then concat(cast(substr(d.APPLY_DATE,1,4)-1 as int),'-',substr(d.APPLY_DATE,1,4))
            when substr(d.APPLY_DATE,5,1)='-' and substr(d.APPLY_DATE,6,1)=0 and substr(d.APPLY_DATE,7,1)>7
            then concat(substr(d.APPLY_DATE,1,4),'-',cast(substr(d.APPLY_DATE,1,4)+1 as int)) end as semester_year,
         c.MEMBER_NAME as first_author_name,
         c.JSLX as first_author_type,
         c.MEMBER_CODE as first_author_code
          from
          (
           select a.PATENT_CODE,a.MEMBER_CODE,a.DEPARTMENT,b.JSLX,collect_list(MEMBER_NAME)[0] as MEMBER_NAME
            from raw.sr_t_ky_zlryxx a
            left join raw.hr_t_jzg b
            on a.member_code=b.ZGH
            where ROLE_TYPE='负责人'
            group by a.PATENT_CODE,a.MEMBER_CODE,a.DEPARTMENT,b.JSLX
            ) c
            left join
             raw.sr_t_ky_zlxx d
             on c.PATENT_CODE=d.PATENT_CODE
        )b
        where b.semester_year='${semester}'
    "
    fn_log "导入数据--科研专利成果信息明细表 :${HIVE_DB}.${HIVE_TABLE}"
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

#第一次执行create_table--getYearData  循环近5年的
#第二+以后次执行import_table where后的变量改成 '${SEMESTER_YEARS}'
init_exit
create_table
getYearData
#import_table
finish
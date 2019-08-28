#!/bin/sh
#################################################
###  基础表:       科研专利作者信息明细表
###  维护人:       guojianing
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_author_patent_info.sh. &
###  结果目标:      model.scientific_author_patent_info
#################################################
cd dirname $0
source ../../config.sh
exec_dir scientific_author_patent_info

HIVE_DB=model
HIVE_TABLE=scientific_author_patent_info
TARGET_TABLE=scientific_author_patent_info

PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	            patent_code STRING COMMENT '专利编号',
                author_code STRING COMMENT '人员工号',
                author STRING COMMENT '作者姓名',
                rank STRING COMMENT '署名顺序',
                author_type STRING COMMENT '作者类型',
                unit STRING COMMENT '作者单位',
                contribution_rate STRING COMMENT '贡献率',
                semeste_year STRING COMMENT '学年'
      )COMMENT '科研专利作者信息明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--科研专利作者信息明细表:${HIVE_DB}.${HIVE_TABLE}"
}


function import_table(){
    hive -e "
        INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
        b.patent_code,
        b.author_code,
        b.author,
        b.rank,
        b.author_type,
        b.unit,
        b.contribution_rate,
        b.semeste_year
        from
        (
            select
            distinct
            a.patent_code as patent_code,
            b.member_code as author_code,
            b.member_name as author,
            '' as rank,
            case when b.role_type=='教师' then '负责人' when  b.role_type=='校外' then '参与者' else '其他' end as author_type,
            b.DEPARTMENT as unit,
            '' as contribution_rate,
            case
            when substr(a.APPLY_DATE,5,1)=0 and substr(a.APPLY_DATE,6,1)<7 then concat(cast(substr(a.APPLY_DATE,1,4)-1 as int),'-',substr(a.APPLY_DATE,1,4))
            when substr(a.APPLY_DATE,5,1)!=0 and substr(a.APPLY_DATE,5,2)>7 then concat(substr(a.APPLY_DATE,1,4),'-',cast(substr(a.APPLY_DATE,1,4)+1 as int))
            when substr(a.APPLY_DATE,5,1)='-' and substr(a.APPLY_DATE,6,1)=0 and substr(a.APPLY_DATE,7,1)<7
            then concat(cast(substr(a.APPLY_DATE,1,4)-1 as int),'-',substr(a.APPLY_DATE,1,4))
            when substr(a.APPLY_DATE,5,1)='-' and substr(a.APPLY_DATE,6,1)=0 and substr(a.APPLY_DATE,7,1)>7
            then concat(substr(a.APPLY_DATE,1,4),'-',cast(substr(a.APPLY_DATE,1,4)+1 as int)) end  as semeste_year
            from
            raw.sr_t_ky_zlxx a
            left join
            raw.sr_t_ky_zlryxx b
            on a.PATENT_CODE=b.patent_code
         ) b where b.semeste_year='${semester}'
    "
    fn_log "导入数据--科研专利作者信息明细表 :${HIVE_DB}.${HIVE_TABLE}"
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
#第二次执行import_table where后的变量改成 '${SEMESTER_YEARS}'
init_exit
create_table
getYearData
#import_table
finish
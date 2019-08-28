#!/bin/sh
#################################################
###  基础表:       科研论文人员明细表
###  维护人:       guojianing
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_paper_personnel_info.sh. &
###  结果目标:      model.scientific_paper_personnel_info
#################################################
cd dirname $0
source ../../config.sh
exec_dir scientific_paper_personnel_info

HIVE_DB=model
HIVE_TABLE=scientific_paper_personnel_info
TARGET_TABLE=scientific_paper_personnel_info

PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	             code STRING COMMENT '论文编号',
                 teacher_code STRING COMMENT '人员工号',
                 teacher_name STRING COMMENT '作者姓名',
                 order_signature STRING COMMENT '署名顺序',
                 author_type STRING COMMENT '作者类型',
                 is_mentor STRING COMMENT '是否导师',
                 is_correspondent STRING COMMENT '是否通讯作者',
                 author_unit STRING COMMENT '作者单位',
                 contribution_rate STRING COMMENT '贡献率',
                 ranking STRING COMMENT '排名',
                 semester_year STRING COMMENT '学年'
      )COMMENT '科研论文人员明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--科研论文人员明细表:${HIVE_DB}.${HIVE_TABLE}"
}
#是否导师  贡献率 排名 署名顺序 作者类型
function import_table(){
    hive -e "
        INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
        b.code,
        b.teacher_code,
        b.teacher_name,
        b.order_signature,
        b.author_type,
        b.is_mentor,
        b.is_correspondent,
        b.author_unit,
        b.contribution_rate,
        b.ranking,
        b.semester_year
        from
        (
        select
        a.PAPER_CODE as	code,
        a.FIRST_AUTHOR_CODE as teacher_code,
        b.AUTHOR_NAME as teacher_name,
        '' as order_signature,
        '' as author_type,
        '' as is_mentor,
        '' as is_correspondent,
        '陕西能源职业技术学院' as author_unit,
        '' as contribution_rate,
        '' as ranking,
        case
			when substr(a.PUBLISH_DATE,5,1)=0 and substr(a.PUBLISH_DATE,6,1)<7 then concat(cast(substr(a.PUBLISH_DATE,1,4)-1 as int),'-',substr(a.PUBLISH_DATE,1,4))
			when substr(a.PUBLISH_DATE,5,1)=0 and substr(a.PUBLISH_DATE,6,1)>7 then concat(substr(a.PUBLISH_DATE,1,4),'-',cast(substr(a.PUBLISH_DATE,1,4)+1 as int))
			when substr(a.PUBLISH_DATE,5,1)!=0 and substr(a.PUBLISH_DATE,5,2)>7 then concat(substr(a.PUBLISH_DATE,1,4),'-',cast(substr(a.PUBLISH_DATE,1,4)+1 as int))
		 end as semester_year
		 from
		raw.sr_T_KY_FBLWXX a left join raw.sr_T_KY_LWRYXX b
		on a.PAPER_CODE=b.PAPER_CODE and a.FIRST_AUTHOR_CODE=b.AUTHOR_CODE

        ) b where b.semester_year='${semester}'

    "
    fn_log "导入数据--科研论文人员明细表 :${HIVE_DB}.${HIVE_TABLE}"
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
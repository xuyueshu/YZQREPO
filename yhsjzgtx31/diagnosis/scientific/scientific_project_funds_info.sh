#!/bin/sh
#################################################
###  基础表:       科研项目经费明细表
###  维护人:       guojianing
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_project_funds_info.sh. &
###  结果目标:      model.scientific_project_funds_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir donation_record

HIVE_DB=model
HIVE_TABLE=scientific_project_funds_info
TARGET_TABLE=scientific_project_funds_info

PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	            code STRING COMMENT '项目编号',
                appropriation_unit STRING COMMENT '拨款单位',
                arrival_account_time STRING COMMENT '到帐时间',
                arrival_account_money STRING COMMENT '到帐金额(万元)',
                plan_total_funds STRING COMMENT '计划经费总额（万元)',
                expenditure_date STRING COMMENT '支出日期',
                semester_year STRING COMMENT '学年'
      )COMMENT '科研项目经费明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--科研项目经费明细表:${HIVE_DB}.${HIVE_TABLE}"
}

#到帐时间 计划经费总额 支出日期 学年
function import_table(){
    hive -e "
        INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
        b.code,
        b.appropriation_unit,
        b.arrival_account_time,
        b.arrival_account_money,
        b.plan_total_funds,
        b.expenditure_date,
        b.semester_year
        from
        (
        select
        a.PROJECT_NO as code,
        case
        when a.BRIEF like '%校级%' then '陕西能源职业技术学院'
        when a.BRIEF like '%教育厅%' then '陕西省教育厅'
        when a.BRIEF like '%省高教工委%' then '陕西省高教工委'
        end as appropriation_unit,
        dk.ARRIVAL_CASH_TIME as arrival_account_time,
        round(dk.ARRIVAL_CASH/10000,4) as arrival_account_money,
        round(a.RESEARCH_MONEY/10000,4) as plan_total_funds,
        '' as expenditure_date,
        case when length(a.SETUP_DATE)=6 then concat(cast(substring(a.SETUP_DATE,1,4) as int),'-',cast(substring(a.SETUP_DATE,1,4) as int)+1)
             else concat(cast(concat('20',substring(a.PROJECT_NO,1,2)) as int),'-',cast(concat('20',substring(a.PROJECT_NO,1,2)) as int)+1) end semester_year
        from
        raw.sr_T_KY_KYXMXX a left join raw.sr_T_KY_KYDKQK dk on a.PROJECT_NO=dk.PROJECT_CODE

        ) b
    "
    fn_log "导入数据--科研项目经费明细表 :${HIVE_DB}.${HIVE_TABLE}"
}


#第一次执行create_table--getYearData  循环近5年的
#第二+以后次执行import_table where后的变量改成 '${SEMESTER_YEARS}'
init_exit
create_table
import_table
finish
#!/bin/sh
#################################################
###  基础表:       校企合作统计表
###  维护人:       ZhangWeiCe
###  数据源:       model.major_donation_major_count,model.basic_major_info

###  导入方式:      全量导入
###  运行命令:      sh major_donation_all_count.sh. &
###  结果目标:      app.major_donation_all_count
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir major_donation_all_count

HIVE_DB=app
HIVE_TABLE=major_donation_all_count
TARGET_TABLE=major_donation_all_count

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
               cooperation_company_count STRING COMMENT '合作企业数量',
               cooperation_major_count STRING COMMENT '合作专业总量',
               major_proportion STRING COMMENT '校企合作专业占比',
              donation_company_count STRING COMMENT '捐赠企业总数',
              donation_device_count STRING COMMENT '捐赠设备总台数',
              donation_device_price_count STRING COMMENT '捐赠设备总值',
              production_education_fuse_project_count STRING COMMENT '产教融合项目数',
              semester_year STRING COMMENT '学年'
      )COMMENT '校企合作统计表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--校企合作统计表 :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
    hive -e " insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            SELECT
                cast(t1.cooperation_company_count as int) as cooperation_company_count,
                cast(t2.cooperation_major_count as int) as cooperation_major_count,
                ROUND(nvl((t2.cooperation_major_count/if(t3.major_num is null,0,t3.major_num)),0),2) as major_proportion,
                cast(t1.donation_company_count as int)  as donation_company_count,
                cast(t1.donation_device_count as int)  as donation_device_count,
                t1.donation_device_price_count as donation_device_price_count,
                0 as production_education_fuse_project_count,
                t1.semester_year
            FROM
            (SELECT
            semester_year,
            SUM(cooperation_company_count) as cooperation_company_count,
            SUM(if(donation_company_count is null,0,donation_company_count)) as donation_company_count,
            SUM(if(donation_device_count is null,0,donation_device_count)) as donation_device_count,
            ROUND(SUM(donation_device_price_count),4) as donation_device_price_count
            from model.major_donation_major_count
            GROUP BY semester_year
            ) t1
            left join
                (SELECT
                    count(1) as cooperation_major_count,
                    semester_year
                 FROM model.major_donation_major_count
                GROUP BY semester_year
            ) t2 on t1.semester_year=t2.semester_year
            left join(
                SELECT
                count(1) as major_num,
                semester_year
                FROM model.basic_major_info
                GROUP BY semester_year
            ) t3 on t1.semester_year=t3.semester_year
    "

    fn_log "导入数据--校企合作统计表 :${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "cooperation_company_count,cooperation_major_count,major_proportion,donation_company_count,donation_device_count,donation_device_price_count,production_education_fuse_project_count,semester_year"

    fn_log "导出数据--校企合作统计表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish
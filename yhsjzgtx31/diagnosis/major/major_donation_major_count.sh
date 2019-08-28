#!/bin/sh
###################################################
###   基础表:      校企合作各专业统计表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_donation_major_count.sh &
###  结果目标:      model.major_donation_major_count
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_donation_major_count

HIVE_DB=model
HIVE_TABLE=major_donation_major_count
TARGET_TABLE=major_donation_major_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        cooperation_company_count   STRING     COMMENT '合作企业数量',
                                        donation_device_price_count   STRING     COMMENT '捐赠设备总值单位（万元）',
                                        dept_code   STRING     COMMENT '系部代码',
                                        dept_name   STRING     COMMENT '系名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称',
                                        semester_year   STRING     COMMENT '学年',
                                        donation_company_count   STRING     COMMENT '捐赠企业总数',
                                        donation_device_count   STRING     COMMENT '捐赠设备总台数',
                                        production_education_fuse_project_count   STRING     COMMENT '产教融合项目数'        )COMMENT  '校企合作各专业统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--校企合作各专业统计表: ${HIVE_DB}.${HIVE_TABLE}"
}
#产教融合项目数没有数据
function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select
                a.qysl cooperation_company_count,
                nvl(b.donation_device_price_count,0) donation_device_price_count,
                a.dept_code dept_code,
                a.dept_name dept_name,
                a.major_code major_code,
                a.major_name major_name,
                a.semester_year semester_year,
                nvl(b.donation_company_count,0) donation_company_count,
                nvl(b.donation_device_count,0) donation_device_count,
                0 production_education_fuse_project_count
                from (
                    select XNMC semester_year,ssxbbh dept_code,ssxb dept_name,HZZYDM major_code,QYZYMC major_name,count(distinct QYMC) qysl
                    from raw.ec_t_zg_hzqyxx
                    group by XNMC,ssxbbh,ssxb,HZZYDM,QYZYMC
                    ) a left join
                    (select XN semester_year,XBBH dept_code,XBMC dept_name,ZYBH major_code,ZYMC major_name,
                    round(sum(JZSBJZ/10000),4) donation_device_price_count,count(distinct HZQYMC) donation_company_count,
                    count(1) donation_device_count
                    from raw.ec_t_zg_qyjzsbxx
                    group by XN,XBBH,XBMC,ZYBH,ZYMC) b on a.semester_year=b.semester_year
                    and a.dept_code=b.dept_code and a.dept_name=b.dept_name
                    and a.major_code=b.major_code and a.major_name=b.major_name
        "
        fn_log " 导入数据--校企合作各专业统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "cooperation_company_count,donation_device_price_count,dept_code,dept_name,major_code,major_name,semester_year,donation_company_count,donation_device_count,production_education_fuse_project_count"

    fn_log "导出数据--校企合作各专业统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
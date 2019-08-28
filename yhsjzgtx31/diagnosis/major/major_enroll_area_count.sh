#!/bin/sh
###################################################
###   基础表:      各地区计划招生人数统计
###   维护人:      ZhangWeiCe
###   数据源:
###  导入方式:      全量导入
###  运行命令:      sh major_enroll_area_count.sh &
###  结果目标:      model.major_enroll_area_count
###################################################
#cd `dirname $0`
source ../../config.sh
#exec_dir major_enroll_area_count

HIVE_DB=model
HIVE_TABLE=major_enroll_area_count
TARGET_TABLE=major_enroll_area_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '系部代码',
                                        academy_name   STRING     COMMENT '系部名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称',
                                        province_code   STRING     COMMENT '省代码',
                                        province_name   STRING     COMMENT '省名称',
                                        city_code   STRING     COMMENT '市代码',
                                        city_name   STRING     COMMENT '市名称',
                                        plan_single_student_count   STRING     COMMENT '计划单招人数',
                                        plan_ordinary_student_count   STRING     COMMENT '计划普招人数',
                                        actual_single_student_count   STRING     COMMENT '实际单招人数',
                                        semester_year   STRING     COMMENT '学年',
                                        actual_ordinary_student_count   STRING     COMMENT '实际普招人数' )COMMENT  '各地区计划招生人数统计'
		LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--各地区计划招生人数统计: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "
		DROP TABLE tmp.major_academy;
		
		CREATE table tmp.major_academy as 
			select 
			zy.xydm as academy_code,
			xy.xymc as academy_name,
			zy.zydm as major_code,
			zy.zymc as major_name
		FROM raw_zsxt.zsxt_xxdm_zydmb zy
		LEFT JOIN raw_zsxt.zsxt_xxdm_xydm xy on zy.xydm=xy.xydm;


		
		insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
		SELECT 
			xyzy.academy_code as academy_code,
			xyzy.academy_name as academy_name,
			xyzy.major_code as major_code,
			xyzy.major_name as major_name,
			zs.ssdm as province_code,
			ss.ssmc as province_name,
			concat(substr(zs.dqdm,1,4),'00') as city_code,
			if(p.tmxx is null,'',p.tmxx) as city_name,
			'' as plan_single_student_count,
			'' as plan_ordinary_student_count,
			'' as actual_single_student_count,
			zs.zsnd as semester_year,
			'' as actual_ordinary_student_count
		FROM raw_zsxt.zsxt_luxsxxb_zsb zs 
		LEFT JOIN tmp.major_academy xyzy on xyzy.major_code=zs.lqzy
		LEFT JOIN raw_zsxt.zsxt_dm_ssdmb ss on zs.ssdm=ss.ssdm
		LEFT JOIN (SELECT tmid,tmxx,ssbm from tmp.provinces_nation where ssbm='DM_GB_B_ZHRMGHGXZQHDM') p on concat(substr(zs.dqdm,1,4),'00')=p.tmid;
		
		DROP TABLE tmp.major_academy;
		"
		
        fn_log " 导入数据--各地区计划招生人数统计: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,academy_name,major_code,major_name,province_code,province_name,city_code,city_name,plan_single_student_count,plan_ordinary_student_count,actual_single_student_count,semester_year,actual_ordinary_student_count"

    fn_log "导出数据--各地区计划招生人数统计: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table

rm -f ${HIVE_TABLE}.java

finish ${HIVE_TABLE}

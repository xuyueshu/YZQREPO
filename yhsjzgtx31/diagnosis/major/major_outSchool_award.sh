#!/bin/sh
###################################################
###   基础表:      学生校外获奖情况
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_outSchool_award.sh &
###  结果目标:      model.major_outSchool_award
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_outSchool_award

HIVE_DB=model
HIVE_TABLE=major_outSchool_award
TARGET_TABLE=major_outSchool_award

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        student_code   STRING     COMMENT '学生编号',
                                        award_name   STRING     COMMENT '获奖名称',
                                        award_time   STRING     COMMENT '获奖年月',
                                        award_type   STRING     COMMENT '获奖类型',
                                        award_category   STRING     COMMENT '获奖类别',
                                        level   STRING     COMMENT '获奖级别（1国家，2省，3市）',
                                        award_grade   STRING     COMMENT '获奖等级（1一等2二等3三等）',
                                        semester_year   STRING     COMMENT '学年',
                                        dept_code   STRING     COMMENT '系部代码',
                                        dept_name   STRING     COMMENT '系部名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称'        )COMMENT  '学生校外获奖情况'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生校外获奖情况: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select a.XH student_code,
               a.XMMC award_name,
               a.CPXN award_time,
               case when a.XMLXMC like '%创新创业%' then 'CXCY' when a.XMLXMC like '%技能%' then 'ZTYLJN'
                    when a.XMLXMC like '%文体%' then 'WHTY' else 'OTHER' end award_type,
               a.XMXZMC award_category,
               case when a.XMXZMC like'%国家%' then 1 when a.XMXZMC like '%省%' then 2 else 3 end  level,
               case when a.HJDJ like'%一等%' then 1 when a.HJDJ like '%二等%' then 2 else 3   end  award_grade,
               XN semester_year,
               c.XBH dept_code,
               c.XMC dept_name,
               b.ZYDM major_code,
               c.ZYMC major_name
        from raw.sw_t_zg_xg_xspjjg a
        left join raw.sw_t_bzks b on a.xh=b.xh
        left join raw.zgy_t_zg_zyxx c on b.zydm=c.ZYDM
        where a.XMCC='校外'
        and b.zydm is not null
        and c.XBH is not null

        "
        fn_log " 导入数据--学生校外获奖情况: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "student_code,award_name,award_time,award_type,award_category,level,award_grade,semester_year,dept_code,dept_name,major_code,major_name"

    fn_log "导出数据--学生校外获奖情况: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
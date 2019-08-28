#!/bin/sh
###################################################
###   基础表:      学生获奖信息表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_award_info

HIVE_DB=model
HIVE_TABLE=student_award_info
TARGET_TABLE=student_award_info
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              academy_code      STRING    COMMENT '系部编号',
              major_code      STRING    COMMENT '专业编号',
              class_code      STRING    COMMENT '班级编号',
              code      STRING    COMMENT '学生编号',
              approval_number      STRING    COMMENT '批准文号',
              award_level      STRING    COMMENT '奖励等级',
              award_name      STRING    COMMENT '奖励名称',
              appraise_company      STRING    COMMENT '评选单位',
              award_time      STRING    COMMENT '获奖时间(yyyy-MM-dd)',
              award_money      STRING    COMMENT '获奖金额',
              award_type      STRING    COMMENT '获奖类型,参见enum_info中HY类型的枚举,保存对应code',
              award_reason      STRING    COMMENT '奖励原因',
              semester_year      STRING    COMMENT '学年',
              semester      STRING    COMMENT '学期'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生获奖信息表--'${HIVE_DB}.${HIVE_TABLE}'"
}
#批准文号?  获奖时间的格式为(yyyy-MM-dd)？  获奖金额？ 学期? 评选单位?
#第一次into 以后overwrite
function import_table(){

        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             distinct
             c.XBH as academy_code,
             b.ZYDM as major_code,
             b.BH as class_code,
             a.XH as code,
             '' as approval_number,
             case when a.XMMC like '%等奖%' then substr(substr(a.XMMC,length(a.XMMC)-4),2,3)
             else '其他' end as award_level,
             a.XMMC as award_name,
             a.XMXZMC as appraise_company,
             a.CPXN as award_time,
             a.JE as award_money,
             case
                when a.XMLXMC='校内技能大赛' or a.XMLXMC='校外技能大赛' then 'ZTYLJN'
                when a.XMLXMC='校内创新创业大赛' or a.XMLXMC='校外创新创业获奖' then 'CXCY'
                else 'OTHER' end as award_type,
             '' as award_reason,
             a.XN as semester_year,
             a.XQ as semester
             from raw.sw_T_ZG_XG_XSPJJG a
             left join
             raw.sw_t_bzks b
             on a.XH=b.XH
             left join
             raw.zgy_t_zg_zyxx c
             on b.ZYDM=c.ZYDM
             where a.XN='${semester}'
        "
        fn_log " 导入数据--学生获奖信息表:${HIVE_DB}.${HIVE_TABLE}"

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

#第一次执行create_table / getYearData  循环近5年的
#第二次执行import_table  where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
#import_table
finish

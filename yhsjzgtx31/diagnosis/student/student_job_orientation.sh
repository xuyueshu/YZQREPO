#!/bin/sh
###################################################
###   基础表:      学生就业去向明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_job_orientation

HIVE_DB=model
HIVE_TABLE=student_job_orientation
TARGET_TABLE=student_job_orientation
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
              graduate_toward      STRING    COMMENT '毕业去向',
              company_name      STRING    COMMENT '就业单位名称',
              company_type      STRING    COMMENT '就业单位性质(HZ：合资，DZ：独资，GY：国有 ，SY：私营 ,QT : 其他)',
              pay_money      STRING    COMMENT '薪资',
              is_counterpart      STRING    COMMENT '是否对口(1对口 2不对口)',
              province      STRING    COMMENT '省',
              city      STRING    COMMENT '市',
              semester_year      STRING    COMMENT '学年'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生就业去向明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}
#毕业去向  就业单位性质  薪资 是否对口 学年
#第一次into 以后overwrite
function import_table(){

        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             distinct
             nvl(c.XBH,' ')as academy_code,
             b.ZYDM as major_code,
             b.BH as class_code,
             a.XH as code,
             nvl(a.BYQXDM,' ') as graduate_toward,
             a.JSDW as company_name,
             case when a.JSDW like '%中铁%' then 'GY' when a.JSDW like '%陕西建工%' then 'GY'
                   when a.JSDW like '%医院%' then 'GY' when a.JSDW like '%政府%' then 'GY'
                   when a.JSDW like '%社区%' then 'GY' when a.JSDW like '%卫生院%' then 'GY'
             else 'SY' end as company_type,
             nvl(a.DWTGDY,' ') as pay_money,
             ' ' as is_counterpart,
             case when substr(a.JSDWDZ,3,1)='省' then substr(a.JSDWDZ,1,3) else ' ' end  as province,
             case when substr(a.JSDWDZ,3,1)='省' then substr(a.JSDWDZ,4,3)
                  when substr(a.JSDWDZ,3,1)='市' then substr(a.JSDWDZ,1,3) else ' ' end as city,
             '${semester}' as semester_year
             from
             raw.oe_T_JY_BYQX a
             left join
             raw.sw_t_bzks b
             on a.XH=b.XH
             right join
             raw.zgy_t_zg_zyxx c
             on b.ZYDM=c.ZYDM
             where substr(a.JSXYRQ,1,4)='${NOW_YEAR}'
             and b.ZYDM is not null

        "
        fn_log " 导入数据--学生就业去向明细表:${HIVE_DB}.${HIVE_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
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

#!/bin/sh
###################################################
###   基础表:      定向培养明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_directed_education

HIVE_DB=model
HIVE_TABLE=student_directed_education
TARGET_TABLE=student_directed_education
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=$((${PRE_YEAR} - 1))"-"${PRE_YEAR}
function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              academy_code      STRING    COMMENT '系部编号',
              academy_name      STRING    COMMENT '系部名称',
              major_code      STRING    COMMENT '专业编号',
              major_name      STRING    COMMENT '专业名称',
              class_code      STRING    COMMENT '班级编号',
              class_name      STRING    COMMENT '班级名称',
              code      STRING    COMMENT '学生编号',
              name      STRING    COMMENT '学生姓名',
              type      STRING    COMMENT '定向培养类型（1订单班，2学徒制，3顶岗实习）',
              course      STRING    COMMENT '课程编号',
              semester_year      STRING    COMMENT '学年'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "定向培养明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}

#订单班所学的 课程
function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
            distinct
             c.XBH as academy_code,
             c.XMC as academy_name,
             c.ZYDM as major_code,
             c.ZYMC as major_name,
             b.BH as class_code,
             d.BJMC as class_name,
             a.XH as code,
             a.XSXM as name,
             case a.PYLX
                    when '订单培养' then 1
                    when '现代学徒制培养' then 2
                    when '其他联合培养' then 3 end as type,
             '' as course,
             a.XNMC as semester_year
             from
             raw.ec_T_ZG_XQHZPYXSXX a
             left join
             raw.sw_t_bzks b
             on a.XH=b.XH
             left join
             raw.zgy_t_zg_zyxx c
             on b.ZYDM=c.ZYDM
             left join
             raw.te_t_bzks_bjap d
             on b.BH=d.BH
        "
        fn_log " 导入数据--定向培养明细表:${HIVE_DB}.${HIVE_TABLE}"

}



init_exit
create_table
import_table
finish
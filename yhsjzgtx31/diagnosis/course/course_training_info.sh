#!/bin/sh
###################################################
###   基础表:      课程实训管理明细
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh course_training_info.sh &
###  结果目标:      model.course_training_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir course_training_info

HIVE_DB=model
HIVE_TABLE=course_training_info
TARGET_TABLE=course_training_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                 course_code   STRING     COMMENT '课程编号',
                 training_name   STRING     COMMENT '实训项目名称',
                 is_open   STRING     COMMENT '是否开出（0：否1：是）',
                 semester_year   STRING     COMMENT '学年',
                 semester   STRING     COMMENT '学期'        )COMMENT  '课程实训管理明细'
                LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--课程实训管理明细: ${HIVE_DB}.${HIVE_TABLE}"
}
#实训项目名称 / 是否开出
function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select
            distinct
            a.KCDM as course_code,
            a.KCMC as training_name,
            case when nvl(JHKCXMS,0)>0 then 1 else 0 end is_open,
            a.XNMC as semester_year,
            a.XQ as semester
            from
            raw.zgy_T_ZG_KCSXJXXXB a
   "
        fn_log " 导入数据--课程实训管理明细: ${HIVE_DB}.${HIVE_TABLE}"

}

init_exit
create_table
import_table
finish
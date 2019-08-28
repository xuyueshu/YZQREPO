#!/bin/sh
###################################################
###   基础表:      学生违纪明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_disciplinary_info.sh &
###  结果目标:      model.student_disciplinary_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_disciplinary_info

HIVE_DB=model
HIVE_TABLE=student_disciplinary_info
TARGET_TABLE=student_disciplinary_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '系部编号',
                                        major_code   STRING     COMMENT '专业编号',
                                        class_code   STRING     COMMENT '班级编号',
                                        code   STRING     COMMENT '学生编号',
                                        disciplinary_time   STRING     COMMENT '违纪时间(yyyy-mm-dd)',
                                        dispose_code   STRING     COMMENT '处分名称码',
                                        dispose_time   STRING     COMMENT '处分日期(yyyy-mm-dd)',
                                        dispose STRING COMMENT '处分详细名称',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期'        )COMMENT  '学生违纪明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生违纪明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
        a.XYDM as academy_code,
        a.ZYDM as major_code,
        a.BJDM as class_code,
        a.XH as code,
        a.WJSJ as disciplinary_time,
        a.CFLBMC as dispose_code,
        a.CFSJ as dispose_time,
        a.wjssjg as dispose,
        a.XN as semester_year,
        substr(a.XQ,2,1) as semester
        from
        raw.sw_T_ZG_XG_WJCFB a
        "
        fn_log " 导入数据--学生违纪明细表: ${HIVE_DB}.${HIVE_TABLE}"

}

create_table
import_table

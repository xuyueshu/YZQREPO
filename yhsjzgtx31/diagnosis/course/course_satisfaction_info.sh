#!/usr/bin/env bash
#################################################
###  基础表:       课程满意度信息表
###  维护人:       Jenkin Zhou.
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh course_satisfaction_info.sh &
###  结果目标:      model.course_satisfaction_info
#################################################

cd `dirname $0`
source ../../config.sh
exec_dir course_satisfaction_info

HIVE_DB=model
HIVE_TABLE=course_satisfaction_info
TARGET_TABLE=course_satisfaction_info

function create_table() {

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

    hive -e "
        CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            semester_year STRING COMMENT '学年',
            semester STRING COMMENT '学期',
            course_code STRING COMMENT '课程代码',
            course_name STRING COMMENT '课程名称',
            teacher_code STRING COMMENT '授课教师代码',
            teacher_name STRING COMMENT '授课教师姓名',
            evaluation_num STRING COMMENT '评价人数',
            score STRING COMMENT '满意度得分',
            academy_code STRING COMMENT '学院编号',
            academy_name STRING COMMENT '学院名称',
            major_code STRING COMMENT '专业编号',
            major_name STRING COMMENT '专业名称'
        )
        COMMENT '课程满意度信息表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建--课程满意度信息表：${HIVE_DB}.${HIVE_TABLE}"
}

#评价人数 满意度得分
function import_table(){

    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
        distinct
        a.KBXN as semester_year,
        a.KBXQ as semester,
        a.KBKCDM as course_code,
        a.KBKCMC as course_name,
        a.JSZGH as teacher_code,
        a.JKJS as teacher_name,
        a.XSRS as evaluation_num,
        nvl(b.KCMYDPM,0)  as score,
        a.XYDM as academy_code,
        a.XYMC as academy_name,
        a.ZYDM as major_code,
        a.ZYMC as major_name
        from
        raw.zgy_T_ZG_JSKB a
        left join
        raw.zgy_T_ZG_JSKBXX b
        on a.KBXN=b.XN and a.JSZGH=b.LSBH and a.KBKCDM=b.KCDM

    "
    fn_log "导入数据--课程满意度信息表：${HIVE_DB}.${HIVE_TABLE}"
}


init_exit
create_table
import_table
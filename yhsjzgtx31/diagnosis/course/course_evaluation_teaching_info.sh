#!/usr/bin/env bash
#################################################
###  基础表:       课程教师评教信息表
###  维护人:       Jenkin Zhou.
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh course_evaluation_teaching_info.sh &
###  结果目标:      model.course_evaluation_teaching_info
#################################################

cd `dirname $0`
source ../../config.sh
exec_dir course_evaluation_teaching_info

HIVE_DB=model
HIVE_TABLE=course_evaluation_teaching_info
TARGET_TABLE=course_evaluation_teaching_info

PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
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
            score STRING COMMENT '评价得分',
            academy_code STRING COMMENT '学院编号',
            academy_name STRING COMMENT '学院名称',
            major_code STRING COMMENT '专业编号',
            major_name STRING COMMENT '专业名称'
        )
        COMMENT '课程教师评教信息表'
        PARTITIONED BY(year STRING COMMENT '统计学年')
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建--课程教师评教信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE} partition ( year = '${semester}')
        select
        a.XNMC as semester_year,
        a.XQMC as semester,
        a.KCDM as course_code,
        a.KCMC as course_name,
        a.LSBH as teacher_code,
        a.LSXM as teacher_name,
        sum(a.CPRS) as evaluation_num,
        sum(a.PJCJ) as score,
        a.SZDWBH as academy_code,
        a.SZDWMC as academy_name,
        b.SYZYDM as major_code,
        b.SYZY as major_name
        from
        raw.zgy_T_ZG_KCKTPJXX a
        left join
        raw.sw_T_ZG_KCXXB b
        on
        a.KCDM=b.KCBH and a.SZDWBH=b.KKYBBH
        and a.LSBH=b.RKJSBH
        where a.XNMC='${semester}'
        group by a.XNMC,a.XQMC,a.KCDM,a.KCMC,a.LSBH,
        a.LSXM,a.SZDWBH,a.SZDWMC,b.SYZYDM,b.SYZY
    "

    fn_log "导入数据--课程教师评教信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function getYearData(){
    vDate=`date +%Y`
    let vDate+=1;
    years=3
    for((i=1;i<=3;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
    done
}

#第一次执行create_table--getYearData  循环近3年的
#第二次执行import_table where后的变量改成 '${SEMESTER_YEARS}'
init_exit
create_table
getYearData
#import_table
finish
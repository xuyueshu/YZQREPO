#!/bin/sh
###################################################
###   基础表:      科研项目基本明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_project_basic_info.sh &
###  结果目标:      model.scientific_project_basic_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir scientific_project_basic_info

HIVE_DB=model
HIVE_TABLE=scientific_project_basic_info
TARGET_TABLE=scientific_project_basic_info

PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '项目编号',
                                        name   STRING     COMMENT '项目名称',
                                        subordinate_unit   STRING     COMMENT '所属单位',
                                        teacher_code   STRING     COMMENT '负责人工号',
                                        teacher_name   STRING     COMMENT '负责人姓名',
                                        project_nature   STRING     COMMENT '项目性质（1纵向项目，2横向项目）',
                                        main_subject   STRING     COMMENT '所属主课题',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '科研项目基本明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--科研项目基本明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        select
        b.code,
        b.name,
        b.subordinate_unit,
        b.teacher_code,
        b.teacher_name,
        b.project_nature,
        b.main_subject,
        b.semester_year
        from
        (
        select
        a.PROJECT_NO as code,
        a.PROJECT_NAME as name,
        '陕西能源职业技术学院' as subordinate_unit,
        a.FUNCTIONARY_NO as teacher_code,
        a.FUNCTIONARY_NAME as teacher_name,
        case when a.PROJECT_TYPE='纵向' then 1 when a.PROJECT_TYPE='横向' then 2 end project_nature,
        a.PROJECT_TYPE_CODE as main_subject,
        case when length(a.SETUP_DATE)=6 then concat(cast(substring(a.SETUP_DATE,1,4) as int),'-',cast(substring(a.SETUP_DATE,1,4) as int)+1)
             else concat(cast(concat('20',substring(a.PROJECT_NO,1,2)) as int),'-',cast(concat('20',substring(a.PROJECT_NO,1,2)) as int)+1) end semester_year
        from
        raw.sr_T_KY_KYXMXX a
        ) b
        "
        fn_log " 导入数据--科研项目基本明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

init_exit
create_table
import_table
#import_table
finish
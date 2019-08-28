#!/bin/sh
###################################################
###   基础表:      教师管理职位明细
###   维护人:      ZhangWeiCe
###   数据源:      model.basic_teacher_info,model.student_community_information,model.basic_instructor_info

###  导入方式:      全量导入
###  运行命令:      sh teacher_managerial_position_record.sh &
###  结果目标:      app.teacher_managerial_position_record
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir teacher_managerial_position_record

HIVE_DB=app
HIVE_TABLE=teacher_managerial_position_record
TARGET_TABLE=teacher_managerial_position_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        is_poverty_alleviation   STRING     COMMENT '是否扶贫教师',
                                        is_instructor   STRING     COMMENT '是否辅导员',
                                        is_community_guidance   STRING     COMMENT '是否社团指导老师'        )COMMENT  '教师管理职位明细'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师管理职位明细: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}

             select
             aa.code as code,
             aa.name as name,
             aa.semester_year as semester_year,
             case when aa.is_poverty_alleviation ='1' then '1'  else '0' end as is_poverty_alleviation,
             case when bb.code is not null then '1' else '0' end as is_instructor,
			 case when cc.code is not null then '1' else '0' end as is_community_guidance

        from model.basic_teacher_info  aa
        left join model.basic_instructor_info bb on aa.code=bb.teacher_code and cast(substr(aa.semester_year,1,4)-1 as int)=bb.grade
        left join model.student_community_information cc on aa.code=cc.teacher_code and aa.semester_year=cc.semester_year



        "
        fn_log " 导入数据--教师管理职位明细: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester_year,is_poverty_alleviation,is_instructor,is_community_guidance"

    fn_log "导出数据--教师管理职位明细: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
#mysql没有该表
#export_table
finish
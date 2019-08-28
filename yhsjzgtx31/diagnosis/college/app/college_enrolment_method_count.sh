#!/bin/sh
###################################################
###   基础表:      学生招生方式统计表
###   维护人:      yangsh
###   数据源:      model.major_enroll_area_count,model.basic_major_info

###  导入方式:      全量导入
###  运行命令:      sh college_enrolment_method_count.sh &
###  结果目标:      app.college_enrolment_method_count
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir college_enrolment_method_count

HIVE_DB=app
HIVE_TABLE=college_enrolment_method_count
TARGET_TABLE=college_enrolment_method_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '系编号',
                                        academy_name   STRING     COMMENT '系名称',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        student_num   STRING     COMMENT '招生总人数',
                                        single_recruit_num   STRING     COMMENT '单招人数',
                                        general_recruitment_num   STRING     COMMENT '普招人数',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '学生招生方式统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生招生方式统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
                    select b.academy_code as academy_code
                    ,b.academy_name as academy_name
                    ,b.code as major_code
                    ,b.name as major_name
                    ,cast(sum(a.actual_single_student_count) + sum(a.actual_ordinary_student_count) as int) as student_num
                    ,cast(sum(a.actual_single_student_count) as int) as single_recruit_num
                    ,cast(sum(a.actual_ordinary_student_count) as int)  as general_recruitment_num
                    ,a.semester_year as semester_year
                    from model.major_enroll_area_count a
                    left join model.basic_major_info b on a.major_code=b.code and a.academy_code=b.academy_code and a.semester_year=b.semester_year
                    group by b.academy_code,b.academy_name,b.code,b.name,a.semester_year
										order by academy_name desc
        "
        fn_log " 导入数据--学生招生方式统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,academy_name,major_code,major_name,student_num,single_recruit_num,general_recruitment_num,semester_year"

    fn_log "导出数据--学生招生方式统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
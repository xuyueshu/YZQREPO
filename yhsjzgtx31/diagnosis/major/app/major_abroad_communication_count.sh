#!/bin/sh
###################################################
###   基础表:      专业国际交流统计表
###   维护人:      ZhangWeiCe
###   数据源:      model.college_exit_record,model.basic_student_info,model.basic_department_info,model.basic_teacher_info

###  导入方式:      全量导入
###  运行命令:      sh major_abroad_communication_count.sh &
###  结果目标:      app.major_abroad_communication_count
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_abroad_communication_count

HIVE_DB=app
HIVE_TABLE=major_abroad_communication_count
TARGET_TABLE=major_abroad_communication_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        dept_code   STRING     COMMENT '二级部门编号',
                        dept_name   STRING     COMMENT '二级部门名称',
                        academy_code   STRING     COMMENT '三级部门代码',
                        academy_name   STRING     COMMENT '三级部门名称',
                        major_code   STRING     COMMENT '专业代码',
                        major_name   STRING     COMMENT '专业名称',
                        semester_year   STRING     COMMENT '学年',
                        student_man_day   STRING     COMMENT '学生境外交流人日',
                        teacher_man_day   STRING     COMMENT '老师境外交流人日',
                        project_num   STRING     COMMENT '境外交流项目数量')COMMENT  '专业国际交流统计表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业国际交流统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            t3.parent_code AS dept_code,
            t3.parent_name AS dept_name,
            t2.academy_code AS academy_code,
            t2.academy_name AS academy_name,
            t2.major_code AS major_code,
            t2.major_name AS major_name,
            t1.semester_year AS semester_year,
            SUM(case when t1.type=2 then 1 else 0 end)*SUM(case when t1.type=2 then visit_days else 0 end) AS student_man_day,
            SUM(case when t1.type=1 then 1 else 0 end)*SUM(case when t1.type=1 then visit_days else 0 end) AS teacher_man_day,
            if(b.num is null,0,b.num) AS project_num
        FROM model.college_exit_record t1
        left join model.basic_student_info t2 on t1.code=t2.code
        left join model.basic_department_info t3 on t2.academy_code=t3.code
        left join model.basic_teacher_info t4 on t4.code=t1.code and t4.academy_code=t2.academy_code
        left join
        ( SELECT
            t2.major_code,
           project_code,
          count(1) as num
        FROM
            model.college_exit_record t1 left join model.basic_student_info t2 on t1.code=t2.code
            LEFT JOIN model.basic_teacher_info t3 ON t3.CODE = t1.CODE
                    AND t3.academy_code = t2.academy_code
            GROUP BY project_code,t2.major_code
            ) b on b.major_code=t2.major_code
        GROUP BY t2.major_code,t3.parent_code,t3.parent_name,t2.academy_code,t2.academy_name,
        t2.major_code ,t2.major_name,t1.semester_year ,b.num
        "
        fn_log " 导入数据--专业国际交流统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "dept_code,dept_name,academy_code,academy_name,major_code,major_name,semester_year,student_man_day,teacher_man_day,project_num"

    fn_log "导出数据--专业国际交流统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
#import_table
#export_table
finish
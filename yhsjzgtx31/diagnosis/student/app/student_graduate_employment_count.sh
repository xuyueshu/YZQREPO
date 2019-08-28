#!/usr/bin/env bash
##########################################################
###  基础表:       学生毕业就业统计表
###  维护人:       ZhangWeiCe
###  数据源:       app.basic_semester_student_info,model.student_graduate_employment_record,model.student_job_orientation

###  导入方式:      全量
###  运行命令:      sh student_graduate_employment_count.sh. &
###  结果目标:      app.student_graduate_employment_count
##########################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_graduate_employment_count

HIVE_DB=app
HIVE_TABLE=student_graduate_employment_count
TARGET_TABLE=student_graduate_employment_count

function create_table() {

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
       academy_code STRING COMMENT '系编号',
        major_code STRING COMMENT '专业编号',
        semester_year STRING COMMENT '学年',
        graduation_num INT COMMENT '毕业人数',
        employment_num INT COMMENT '就业人数',
        employment_rate decimal(10,2) COMMENT '就业率',
        graduation_rate decimal(10,2) COMMENT '毕业率',
        major_num INT COMMENT '专业人数',
        academy_name  STRING COMMENT '系名称',
        major_name  STRING COMMENT '专业名称'
    ) COMMENT '学生毕业就业统计表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——：${HIVE_DB}.${HIVE_TABLE}"
}

#导入数据
function import_table(){
    hive -e "
        insert into table ${HIVE_DB}.${HIVE_TABLE}
            SELECT
               t1.academy_code,
                t1.major_code,
                t1.semester_year,
                if(t2.graduation_num is null,0,t2.graduation_num) as graduation_num,
                if(t3.employment_num is null,0,t3.employment_num) as employment_num,
                cast(nvl(employment_num/graduation_num,0) as decimal(9,2)) employment_rate,
                cast(nvl(graduation_num/t1.major_num,0) as decimal(9,2)) graduation_rate,
                t1.major_num,
                t1.academy_name,
                t1.major_name
            from
            ( SELECT aa.academy_code,aa.major_code, aa.semester_year,aa.academy_name,aa.major_name,count(1) AS major_num FROM
app.basic_semester_student_info aa
left join model.basic_student_info bb
on aa.code =bb.code
where
 CONCAT(cast(substr(bb.grade,1,4)+educational_system-1 as int))=CONCAT(cast(substr(aa.semester_year,1,4) as int))
GROUP BY aa.academy_code,aa.major_code, aa.semester_year,aa.academy_name,aa.major_name) t1
            left join
                (SELECT b.major_code as major_code,b.semester_year,count(1) as graduation_num from model.student_graduate_employment_record a left join app.basic_semester_student_info b on
                a.code=b.code GROUP BY b.major_code,b.semester_year ) t2
              on t1.major_code=t2.major_code and t1.semester_year=t2.semester_year
            left join
                (SELECT major_code,semester_year,count(1) as employment_num from model.student_job_orientation
                GROUP BY major_code,semester_year) t3
            on t1.major_code=t3.major_code and t1.semester_year=t3.semester_year
        "
    fn_log "导入数据 —— 学生毕业就业统计表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'academy_code,major_code,semester_year,graduation_num,employment_num,employment_rate,graduation_rate,major_num,academy_name,major_name'

    fn_log "导出数据--学生毕业就业统计表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish
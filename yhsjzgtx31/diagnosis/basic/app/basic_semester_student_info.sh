#!/bin/sh
#################################################
###  基础表:       学期学生信息表
###  维护人:       王浩
###  数据源:       model.basic_student_info,app.basic_semester_info

###  导入方式:      全量导入
###  运行命令:      sh basic_semester_student_info.sh. &
###  结果目标:      app.basic_semester_student_info
#################################################
cd `dirname $0`
source ../../../config.sh

exec_dir basic_semester_student_info

HIVE_DB=app
HIVE_TABLE=basic_semester_student_info
TARGET_TABLE=basic_semester_student_info


function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
          code STRING  COMMENT '学号',
          class_code STRING  COMMENT '班级代码',
          class_name STRING  COMMENT '班级名称',
          major_code STRING  COMMENT '专业代码',
          major_name STRING  COMMENT '专业名称',
          academy_code STRING  COMMENT '院系代码',
          academy_name STRING  COMMENT '院系名称',
          semester_year STRING  COMMENT '学年',
          semester STRING  COMMENT '学期'
      )COMMENT '学期学生信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "

   fn_log "CREATE EXTERNAL TABLE:${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

    hive -e "
        INSERT OVERWRITE table ${HIVE_DB}.${HIVE_TABLE}
                 select
                    distinct
                    stu.code,
                    stu.class_code,
                    stu.class_name,
                    stu.major_code,
                    nvl(stu.major_name,' '),
                    nvl(stu.academy_code,' '),
                    nvl(stu.academy_name,' '),
                    sem.semester_year,
                    sem.semester
                FROM model.basic_student_info stu,model.basic_semester_info sem
                WHERE cast(stu.grade as INT) + cast(stu.educational_system as INT) > cast(substr(sem.semester_year,0,4) as INT)
                AND cast(stu.grade as INT) <= cast(substr(sem.semester_year,0,4) as INT)

    "
    fn_log "IMPORT TABLE:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,class_code,class_name,major_code,major_name,academy_code,academy_name,semester_year,semester"

    fn_log "EXPORT TABLE:${HIVE_DB}.${HIVE_TABLE}"
}

init_exit
create_table
import_table
export_table
finish
#!/bin/sh
#################################################
###  基础表:       订单班学生信息表
###  维护人:       ZhangWeiCe
###  数据源:       model.student_directed_education

###  导入方式:      全量导入
###  运行命令:      sh major_plan_student.sh. &
###  结果目标:      app.major_plan_student
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir major_plan_student

HIVE_DB=app
HIVE_TABLE=major_plan_student
TARGET_TABLE=major_plan_student

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	       major_code STRING COMMENT '专业编号',
          major_name STRING COMMENT '专业名称',
          academy_code STRING COMMENT '学院编号',
          academy_name STRING COMMENT '学院名称',
          student_count STRING COMMENT '学生人数',
          type STRING COMMENT '1订单班，2学徒制，3顶岗实习',
          semester_year STRING COMMENT '学年'
      )COMMENT '订单班学生信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--订单班学生信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
    hive -e "
            insert overwrite table ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                    nvl(major_code,'') major_code,
                    nvl(major_name,'') major_name,
                    nvl(academy_code,'') academy_code,
                    nvl( academy_name,'') academy_name ,
                    count(1) AS student_count,
                    '1' AS type,
                    semester_year
                FROM model.student_directed_education WHERE type=1
                GROUP BY major_code,major_name,academy_code,academy_name,type,semester_year
    "
     fn_log "导入数据--订单班学生信息 :${HIVE_DB}.${HIVE_TABLE}"

     hive -e "
            insert into table ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                    nvl(major_code,'') major_code,
                    nvl(major_name,'') major_name,
                    nvl(academy_code,'') academy_code,
                    nvl( academy_name,'') academy_name ,
                    count(1) AS student_count,
                    '2' AS type,
                    semester_year
                FROM model.student_directed_education WHERE type=2
                GROUP BY major_code,major_name,academy_code,academy_name,type,semester_year
    "
    fn_log "导入数据--学徒制学生信息 :${HIVE_DB}.${HIVE_TABLE}"

    hive -e "
            insert into table ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                    nvl(major_code,'') major_code,
                    nvl(major_name,'') major_name,
                    nvl(academy_code,'') academy_code,
                    nvl( academy_name,'') academy_name ,
                    count(1) AS student_count,
                    '3' AS type,
                    semester_year
                FROM model.student_directed_education WHERE type=3
                GROUP BY major_code,major_name,academy_code,academy_name,type,semester_year
    "
    fn_log "导入数据--顶岗实习学生信息 :${HIVE_DB}.${HIVE_TABLE}"
}


function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "major_code,major_name,academy_code,academy_name,student_count,type,semester_year"

    fn_log "导出数据--订单班学生信息表:${HIVE_DB}.${TARGET_TABLE}"
}
init_exit
create_table
import_table
export_table
finish
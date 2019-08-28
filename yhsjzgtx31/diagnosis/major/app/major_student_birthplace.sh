#!/bin/sh
#################################################
###  基础表:       学生的生源地信息表
###  维护人:       郭嘉宁
###  数据源:       model.basic_student_info

###  导入方式:      全量导入
###  运行命令:      sh major_student_birthplace.sh. &
###  结果目标:      app.major_student_birthplace
#################################################
cd `dirname $0`
source ../../../config.sh
exec_dir major_student_birthplace

HIVE_DB=app
HIVE_TABLE=major_student_birthplace
TARGET_TABLE=major_student_birthplace

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	      code STRING COMMENT '学生编号',
	      name STRING COMMENT '学生姓名',
	      major_code STRING COMMENT '专业编号',
          major_name STRING COMMENT '专业名称',
          academy_code STRING COMMENT '学院编号',
          academy_name STRING COMMENT '学院名称',
          province STRING COMMENT '来源省份',
          city STRING COMMENT '来源城市',
          score DECIMAL(10,2) COMMENT '学生高考分数',
          applying_major STRING COMMENT '第一志愿报专业',
          semester_year STRING COMMENT '学年'
      )COMMENT '学生的生源地信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--学生的生源地信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
         select
            code,
            name,
            nvl(major_code,'') major_code,
            nvl(major_name,'') major_name,
            nvl(academy_code,'') academy_code,
            nvl(academy_name,'') academy_name,
            nvl(province,'') province,
            nvl(city,'') city,
            nvl(b.KSZF,0) score,
            nvl(b.LQZYDM,'') applying_major,
            concat(substr(grade,0,4),'-',(cast(substr(grade,0,4) as int)+1)) as semester_year
        from
            model.basic_student_info a
            left join raw.rs_t_zg_ksxx b on a.code=b.XH
    "

    fn_log "导出数据--学生的生源地信息表 :${HIVE_DB}.${HIVE_TABLE}"
}


function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,major_code,major_name,academy_code,academy_name,province,city,score,applying_major,semester_year"

    fn_log "导出数据--学生的生源地信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish
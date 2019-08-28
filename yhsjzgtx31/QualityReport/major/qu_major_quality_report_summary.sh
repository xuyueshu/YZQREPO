#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_major_quality_report_summary
#专业层面汇总信息
HIVE_DB=assurance
TARGET_TABLE=qu_major_quality_report_summary
HIVE_TABLE=qu_major_quality_report_summary
function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号',
                major_no  String comment '专业编号',
                major_name String comment '专业名称',
                class_name String comment '所属大类',
                department_name String comment '所属院系',
                create_time String comment '创建时间'
    ) COMMENT '专业层面汇总信息'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——专业层面汇总信息：${HIVE_DB}.${HIVE_TABLE}"
}



function import_table() {
       hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
          SELECT
          concat('${SEMESTER_YEARS}','${SEMESTERS}','MAJOR') as report_no,
          a.major_no as major_no,
          a.major_name as  major_name,
          a.class_name as  class_name,
          a.department_name as  department_name,
          FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
          from
          (
              select
              a.code as major_no,
              a.name as major_name,
              (case when a.discipline_type='LGNY' then '理工农医类'
                                   when a.discipline_type='RWSK' then '人文社科类'
                                   when a.discipline_type='QT' then '其他类' else '' end) as class_name,
              a.academy_code as department_name
              from
              model.basic_major_info a
              where
              a.semester_year='${SEMESTER_YEARS}'
          ) a
         "
    fn_log "导入数据 —— 专业层面质控点信息：${HIVE_DB}.${HIVE_TABLE}"

}

function export_table() {

    clear_mysql_data "delete from qu_major_quality_report_summary where
    substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,major_no,major_name,class_name,department_name,create_time'
    fn_log "导出数据--专业层面质控点信息:${HIVE_DB}.${TARGET_TABLE}"
}

function select_semester_year() {

    SEMESTER_YEARS=`find_mysql_data "
    select semester_year from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
     "`
    SEMESTERS=`find_mysql_data "
    select semester from base_school_calendar_info
    where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;
    "`

    if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEAR IS NULL!"
    else
         echo "SEMESTER_YEAR IS NOT NULL"
         create_table
         import_table
         export_table

    fi

}

function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
    years=2
    for((i=1;i<=2;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      SEMESTER_YEARS=${PRE_YEAR}"-"${NOW_YEAR}
      for((j=1;j<=2;j++));
      do
      SEMESTERS=${j}
      echo $SEMESTER_YEARS"=="$SEMESTERS
      done
    done
}

getYearData
finish


#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_teacher_diagnosis_report_research_service

HIVE_DB=assurance
HIVE_TABLE=qu_teacher_diagnosis_report_research_service
TARGET_TABLE=qu_teacher_diagnosis_report_research_service


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期教师编号',
                send_type  String comment '发布类别',
                object_name  String comment '项目名称',
                send_time String comment '发布时间  格式：yyyymmdd',
                send_note  String comment '备注',
                create_time String comment '创建时间'
    ) COMMENT '教师科研与服务'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——教师科研与服务：${HIVE_DB}.${HIVE_TABLE}"

}

#论文、专利、专著、社会服务
function import_table() {
        hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             SELECT
             distinct
             CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.first_author_code)  as report_no,
             '论文' as send_type,
             a.chinese_name as object_name,
             a.publication_time as send_time,
             a.grade_type as send_note,
             FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
             from
             model.scientific_paper_basic_info a
             where a.semester_year='${SEMESTER_YEARS}'

             UNION ALL

              SELECT
              distinct
             CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.first_author_code)  as report_no,
             '专利' as send_type,
             a.patent_name as object_name,
             ''  as send_time,
             a.patent_type as send_note,
             FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
             from
             model.scientific_patent_achievements a
             where a.semester_year='${SEMESTER_YEARS}'

             UNION ALL

             SELECT
             distinct
             CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.first_author_code)  as report_no,
             '著作' as send_type,
             a.chinese_name as object_name,
             a.publication_date as send_time,
             a.level as send_note,
             FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
             from
             model.scientific_work_basic_info a
              where a.semester_year='${SEMESTER_YEARS}'

              UNION ALL

             SELECT
             distinct
             CONCAT('${SEMESTER_YEARS}','${SEMESTERS}',a.teacher_code)  as report_no,
             '社会服务' as send_type,
             a.project_name as object_name,
             '' as send_time,
             '' as send_note,
             FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
             from
             model.teacher_social_work a
             where a.semester_year='${SEMESTER_YEARS}'


            "
        fn_log "导入数据 —— 教师科研与服务：${HIVE_DB}.${HIVE_TABLE}"

}

function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}'
    and substr(report_no,10,1)='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,send_type,object_name,send_time,send_note,create_time'

    fn_log "导出数据--教师科研与服务:${HIVE_DB}.${TARGET_TABLE}"
}

#判断并执行，抽取最新时间的数据
function select_semester_year(){
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

#抽取近两年的数据
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
        create_table
         import_table
         export_table

      done
    done
}

#最新数据
select_semester_year >> ${RUNLOG} 2>&1
#近两年数据执行
#getYearData>> ${RUNLOG} 2>&1
finish



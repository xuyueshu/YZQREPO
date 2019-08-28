#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_student_diagnosis_report_score_sort

HIVE_DB=assurance
HIVE_TABLE=qu_student_diagnosis_report_score_sort
TARGET_TABLE=qu_student_diagnosis_report_score_sort


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期学生编号(关联表qu_teacher_diagnosis_report_record)',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                semester String comment '学期 1 第一学期 2 第二学期',
                award_count String comment '总成绩',
                mojor_sort String comment '专业排名',
                class_sort String comment '班级排名',
                create_time String comment '创建时间'
    ) COMMENT '学生自诊成绩排名信息'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学生自诊成绩排名信息：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                  cast(sum(a.score) as decimal(9,1)) as award_count,
                  a.major_ranking as mojor_sort,
                  a.class_ranking  as class_sort,
                 FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
             from
                model.student_score_record a
                left join app.course_feedback b
                on a.course_code = b.course_code
                where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
                group by a.code,a.major_ranking,a.class_ranking

            "
    fn_log "导入数据 —— 学生自诊成绩排名信息：${HIVE_DB}.${HIVE_TABLE}"

}

function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}'
    and substr(report_no,10,1)='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,semester,award_count,mojor_sort,class_sort,create_time'

    fn_log "导出数据--学生自诊成绩排名信息:${HIVE_DB}.${TARGET_TABLE}"
}

#判断并执行最新时间的数据
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
#导入最近2年学年学期数据
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


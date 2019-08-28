#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_student_diagnosis_report_score

HIVE_DB=assurance
HIVE_TABLE=qu_student_diagnosis_report_score
TARGET_TABLE=qu_student_diagnosis_report_score


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期学生编号(关联表qu_teacher_diagnosis_report_record)',
                course_name  String comment '课程名称',
                teacher_name String comment '任课老师',
                course_score String comment '成绩  保留一位小数',
                major_avg String comment '专业平均分',
                mojor_sort String comment '专业排名',
                create_time String comment '创建时间'
    ) COMMENT '学生自诊成绩信息'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学生自诊成绩信息：${HIVE_DB}.${HIVE_TABLE}"
}

function tmp_table() {
     hive -e "
        drop table tmp.tmp_student_course;
     "
     hive -e "
         create TABLE tmp.tmp_student_course AS
            select
                a.course_code as course_code ,
                a.major_code as major_code,
                a.semester_year,
                a.semester,
                cast(avg(b.score) as decimal(9,1)) as num
                from
                app.course_feedback a left join model.student_score_record b
                on  a.course_code = b.course_code
                group by a.course_code,a.major_code,
                a.semester_year,
                a.semester
                having cast(avg(b.score) as decimal(9,2)) is not null
            "
            fn_log "导入临时数据 —— 班级在专业中的平均成绩：${HIVE_DB}.${HIVE_TABLE}"
}
function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                a.course_name as course_name,
                b.teacher_name as teacher_name,
                cast(a.score as decimal(3,1)) as course_score,
                cast(nvl(sc.num,0) as decimal(3,1))  as  major_avg,
                cast(a.major_ranking as int) as mojor_sort,
                FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
             from
             model.student_score_record a
             left join app.course_feedback b
             on  a.course_code = b.course_code
             left join tmp.tmp_student_course sc
             on a.course_code=sc.course_code
             and b.major_code = sc.major_code
             where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
            "
    fn_log "导入数据 —— 学生自诊成绩信息：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}'
    and substr(report_no,10,1)='${SEMESTERS}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,course_name,teacher_name,course_score,major_avg,mojor_sort,create_time'

    fn_log "导出数据--学生自诊成绩信息:${HIVE_DB}.${TARGET_TABLE}"
}


#判断并执行
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
      create_table
      import_table
      export_table

      done
    done
}
#select_semester_year
#tmp_table
getYearData
finish



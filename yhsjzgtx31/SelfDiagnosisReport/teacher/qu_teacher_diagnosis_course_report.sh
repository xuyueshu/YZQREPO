#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_teacher_diagnosis_course_report

HIVE_DB=assurance
HIVE_TABLE=qu_teacher_diagnosis_course_report
TARGET_TABLE=qu_teacher_diagnosis_course_report


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期教师编号(关联表qu_teacher_diagnosis_report_record)',
                course_code  String comment '课程编号',
                course_name  String comment '课程名称',
                class_no String comment '班级编号',
                class_name String comment '班级名称',
                student_num String comment '学生总数',
                avg_score String comment '平均分',
                pass_num  String comment '考试通过人数',
                create_time String comment '创建时间'
    ) COMMENT '教师代课详情表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——教师代课详情表：${HIVE_DB}.${HIVE_TABLE}"



}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                a.course_code as course_code,
                a.course_name as course_name,
                a.class_code as class_code,
                a.class_name as class_name,
                cast(a.student_num as int) as student_num,
                nvl(cast(a.avg_score as decimal(3,1)),0) as avg_score,
                cast(a.pass_num as int)as  pass_num,
                FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
             from
                (
                     select
                     a.code,
                     c.course_code,
                     c.course_name,
                     a.class_code,
                     a.class_name,
                     count(distinct b.code) as student_num,
                     cast(avg(c.score) as decimal(9,2)) as avg_score,
                     count(distinct case when c.score > 60 then b.code end) as pass_num
                     from
                     app.teacher_lessons_info a left join
                     app.basic_semester_student_info b
                     on a.class_code=b.class_code
                     left join
                     model.student_score_record c
                     on b.code=c.code
                     where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
                     and c.course_code !=''
                     group by  a.code,
                     c.course_code,
                     c.course_name,
                     a.class_code,
                     a.class_name
                ) a
            "
    fn_log "导入数据 —— 教师代课详情表：${HIVE_DB}.${HIVE_TABLE}"

}
function export_table() {
   clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,course_code,course_name,class_no,class_name,student_num,avg_score,pass_num,create_time'

    fn_log "导出数据--教师代课详情表:${HIVE_DB}.${TARGET_TABLE}"
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
        create_table
        import_table
        export_table
      done
    done
}

#最新数据执行
#select_semester_year
#进两年数据执行
getYearData
finish



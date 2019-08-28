#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_course_diagnosis_report_score

HIVE_DB=assurance
HIVE_TABLE=qu_course_diagnosis_report_score
TARGET_TABLE=qu_course_diagnosis_report_score


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期课程编号',
                major_name  String comment '专业名称',
                class_name  String comment '班级名称',
                course_nature String comment '课程性质 专业核心课 非核心课程',
                course_hour String comment '课时',
                student_num String comment '学生人数',
                fail_num String comment '挂科学生数',
                avg_score String comment '平均分',
                create_time String comment '创建时间'
    ) COMMENT '课程成绩信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——课程成绩信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
     hive -e "
         INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}',b.course_code) as report_no,
                a.major_name as major_name,
                a.name as class_name,
                case when b.course_type='BX' then '专业核心课'
                     when b.course_type='XW' then '专业核心课'
                     when b.course_type='XX' then '非核心课程'
                     when b.course_type='RX' then '非核心课程'
                end as course_nature,
                cast(sum(b.sum_class_hour) as int) as course_hour,
                cast(count(a.code) as int) as student_num,
                cast(count(case when c.score<60 then a.code end) as int) as fail_num,
                cast(avg(c.score) as decimal(9,2)) as avg_score,
                FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
             from
                 model.basic_class_info a
                 left join
                 model.major_course_record b
                 on a.major_code=b.major_code
                 left join
                 model.student_score_record c
                 on b.course_code=c.course_code
                 where b.semester_year='${SEMESTER_YEARS}' and b.semester='${SEMESTERS}'
                 and b.course_code is not null
                 group by a.major_name,a.name,b.course_code,b.course_type

            "
    fn_log "导入数据 —— 课程成绩信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
   clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,major_name,class_name,course_nature,course_hour,student_num,fail_num,avg_score,create_time'

    fn_log "导出数据--课程成绩信息表:${HIVE_DB}.${TARGET_TABLE}"
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
        echo "SEMESTER_YEAR IS NULL!"
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
select_semester_year
#进两年数据执行
#getYearData
finish




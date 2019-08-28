#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_course_diagnosis_report_team

HIVE_DB=assurance
HIVE_TABLE=qu_course_diagnosis_report_team
TARGET_TABLE=qu_course_diagnosis_report_team


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期课程编号',
                teacher_no  String comment '教师编号',
                teacher_name  String comment '教师名称',
                job_title String comment '职称',
                education String comment '学历',
                is_double_professionally String comment '是否是双师素质教师',
                create_time String comment '创建时间'
    ) COMMENT '课程团队信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——课程团队信息表：${HIVE_DB}.${HIVE_TABLE}"
}
function import_table() {
      hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                concat('${SEMESTER_YEARS}','${SEMESTERS}',a.course_code) as report_no,
                a.code as teacher_no,
                a.name as teacher_name,
                b.professional_title as job_title,
                b.education as education,
                case when b.is_double_professionally='0' then '否' else '是' end  as is_double_professionally,
                FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
             from
                model.teacher_course_info a
                left join
                model.basic_teacher_info b
                on a.code=b.code
                where a.semester_year = '${SEMESTER_YEARS}' and a.semester = '${SEMESTERS}'
            "
    fn_log "导入数据 —— 课程团队信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
   clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,teacher_no,teacher_name,job_title,education,is_double_professionally,create_time'

    fn_log "导出数据--课程团队信息表:${HIVE_DB}.${TARGET_TABLE}"
}

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
#近两年数据执行
#getYearData
finish





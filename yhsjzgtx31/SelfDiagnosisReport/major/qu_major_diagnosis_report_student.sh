#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_major_diagnosis_report_student

HIVE_DB=assurance
HIVE_TABLE=qu_major_diagnosis_report_student
TARGET_TABLE=qu_major_diagnosis_report_student

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期专业编号',
                grade_name  String comment '年级名称',
                male_num String comment '男生数量',
                female_num String comment '女生数量',
                create_time String comment '创建时间'
    ) COMMENT '专业学生人数信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——专业学生人数信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                 c.grade as grade_name,
                 count(case when c.sex = '1' then b.code end) as male_num,
                 count(case when c.sex = '2' then b.code end) as female_num,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
             model.basic_major_info a left join
             app.basic_semester_student_info b  on a.code = b.major_code  left join
             model.basic_student_info c
             on b.code=c.code and a.code=c.major_code and b.major_code=c.major_code
             where a.semester_year =  '${SEMESTER_YEARS}' and
             b.semester_year='${SEMESTER_YEARS}' and b.semester='${SEMESTERS}'
             group by a.code,c.grade

            "
    fn_log "导入数据 —— 专业学生人数信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
   clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,grade_name,male_num,female_num,create_time'

    fn_log "导出数据--专业学生人数信息表:${HIVE_DB}.${TARGET_TABLE}"
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
        #开始依次执行
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

#最新学年学期执行
select_semester_year
#需要最近两年的学年学期数据执行
#getYearData
finish






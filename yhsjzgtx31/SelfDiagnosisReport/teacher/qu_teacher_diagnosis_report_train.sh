#!/bin/sh
cd `dirname $0`
source ./../config.sh
exec_dir qu_teacher_diagnosis_report_train

HIVE_DB=assurance
HIVE_TABLE=qu_teacher_diagnosis_report_train
TARGET_TABLE=qu_teacher_diagnosis_report_train


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期教师编号',
                object_name  String comment '项目名称',
                start_time String comment '开始时间  格式：yyyymmdd',
                end_time String comment '结束时间  格式：yyyymmdd',
                prize_type  String comment '证书&荣耀',
                create_time String comment '创建时间'
    ) COMMENT '教师参加培训情况'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——教师参加培训情况：${HIVE_DB}.${HIVE_TABLE}"

}


function import_table() {
        hive -e "
                 INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                     select
                         concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                         a.object_name as object_name,
                         a.start_time as start_time,
                         a.end_time as end_time,
                         a.prize_type as prize_type,
                         FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
                     from
                        (
                         select
                            distinct
                            a.code,
                            a.remark as object_name,
                            a.start_time as start_time,
                            a.end_time as end_time,
                            a.prize_type as prize_type
                            from
                            model.teacher_growing_info a
                            where a.semester_year =  '${SEMESTER_YEARS}'
                        )a
                    "
            fn_log "导入数据 —— 教师参加培训情况：${HIVE_DB}.${HIVE_TABLE}"



}

function export_table() {
    clear_mysql_data "delete from ${TARGET_TABLE} where substr(report_no,1,9)='${SEMESTER_YEARS}'
    and substr(report_no,10,1)='${SEMESTERS}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,object_name,start_time,end_time,prize_type,create_time'

    fn_log "导出数据--教师参加培训情况:${HIVE_DB}.${TARGET_TABLE}"
}

#判断并执行，抽取最新数据
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



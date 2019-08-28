#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_student_diagnosis_report_award

HIVE_DB=assurance
HIVE_TABLE=qu_student_diagnosis_report_award
TARGET_TABLE=qu_student_diagnosis_report_award


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期学生编号(关联表qu_teacher_diagnosis_report_record)',
                award_type  String comment '奖项类型 证书 CERTIFICATE 奖项 AWARD',
                award_name String comment '证书或奖项名称',
                award_level String comment '证书或奖项级别',
                award_date String comment '获取证书或奖项时间  格式：yyyymmdd',
                create_time String comment '创建时间'
    ) COMMENT '学生自诊成绩信息'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学生自诊成绩信息：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {

    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            SELECT
             concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
             'CERTIFICATE' as award_type,
             a.name as award_name,
             case when a.papers_level='CJ' then '初级'
                  when a.papers_level='ZJ' then '中级'
                  when a.papers_level='GJ' then '高级'
                  when a.papers_level='WD' then '无等级' end as award_level,
             a.get_time as award_date,
             FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time from
             model.student_papers a  where a.semester_year = '${SEMESTER_YEARS}'
             and a.semester= '${SEMESTERS}'

             UNION ALL

             SELECT
                concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                'AWARD' as award_type,
                case when a.award_type='ZTYLJN' then '专业类技能大赛'
                      when a.award_type='CXCY' then '创新创业赛获奖'
                      when a.award_type='KJWH' then '科技文化作品'
                      when a.award_type='JCXK' then '基础性学科竞赛'
                      when a.award_type='WHTY' then '文化体育竞赛'
                       when a.award_type='OTHER' then '其他' end as award_name,
                 a.award_level as award_level,
                 a.get_time as  award_date,
                 FROM_UNIXTIME(UNIX_TIMESTAMP())  as create_time
                 from app.student_award_record  a where a.semester_year = '${SEMESTER_YEARS}'
                 and a.semester= '${SEMESTERS}'
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
    --columns 'report_no,award_type,award_name,award_level,award_date,create_time'

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

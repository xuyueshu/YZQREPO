#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_course_quality_report

##课程层面质量报告
# exec_dir方法：如果在单独执行下面方法时，可以根据需要将方法中的exec_dir方法放开进行查看日志，
# 如果统一执行全部方法时将日志在  ./logs/$0_`date +%Y-%m-%d`.log 2>&1 下
# getYearData方法 执行近两年的1，2学期的数据
# select_semester_year方法执行最新学年学期数据
# plan_getYearData方法执行规划数据

HIVE_DB=assurance
TARGET_TABLE=qu_course_quality_report
function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '课程层面质量报告'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
    fn_log "创建表——课程层面质量报告：${HIVE_DB}.${HIVE_TABLE}"
}
function export_table() {
     clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,item_key,item_value,create_time'
    fn_log "导出数据--课程层面质量报告:${HIVE_DB}.${TARGET_TABLE}"
}
#开设课程数量
function import_table_KSKCSL(){
#exec_dir qu_course_quality_report_KSKCSL
HIVE_TABLE=qu_course_quality_report_KSKCSL
ITEM_KEY=KSKCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(distinct a.course_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
             from
                  model.major_course_record a
                  where
                   a.is_open='1'  and a.semester_year = '${SEMESTER_YEARS}'
                  and a.semester='${SEMESTERS}'

            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#理论类课程数量
function import_table_LLLKCSL(){
#exec_dir qu_course_quality_report_LLLKCSL
HIVE_TABLE=qu_course_quality_report_LLLKCSL
ITEM_KEY=LLLKCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(distinct a.course_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.major_course_record a
                  where
                   a.is_open='1'
                  and a.category = '0' and a.semester_year = '${SEMESTER_YEARS}'
                  and a.semester='${SEMESTERS}'

            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#占比(理论类课程数量/开设课程数量*100%)
function import_table_LLLCCSLKSKCSLZB(){
#exec_dir qu_course_quality_report_LLLCCSLKSKCSLZB
HIVE_TABLE=qu_course_quality_report_LLLCCSLKSKCSLZB
ITEM_KEY=LLLCCSLKSKCSLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 nvl(concat(cast(count(distinct case when a.category = '0' then a.course_code end)/count(distinct a.course_code)*100 as decimal(9,2)),'%'),0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.major_course_record a
                  where
                  a.is_open='1' and a.semester_year = '${SEMESTER_YEARS}'
                  and a.semester='${SEMESTERS}'

            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#理论+实践类课程数量
function import_table_LLJSJLCSL(){
#exec_dir qu_course_quality_report_LLJSJLCSL
HIVE_TABLE=qu_course_quality_report_LLJSJLCSL
ITEM_KEY=LLJSJLCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(distinct a.course_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.major_course_record a
                  where
                  a.is_open='1'
                  and a.category = '2' and  a.semester_year = '${SEMESTER_YEARS}'
                  and a.semester='${SEMESTERS}'

            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#占比(理论+实践类课程数量/开设课程数量*100%)
function import_table_LLJSJLCSLKCSLZB(){
#exec_dir qu_course_quality_report_LLJSJLCSLKCSLZB
HIVE_TABLE=qu_course_quality_report_LLJSJLCSLKCSLZB
ITEM_KEY=LLJSJLCSLKCSLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                nvl(concat(cast(count(distinct case when a.category = '2' then a.course_code end) / count(a.course_code)*100 as decimal(9,2)),'%'),0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.major_course_record a
                where
                a.is_open='1' and a.semester_year = '${SEMESTER_YEARS}'
                and a.semester='${SEMESTERS}'

            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#实践类课程数量
function import_table_SJKCSL(){
#exec_dir qu_course_quality_report_SJKCSL
HIVE_TABLE=qu_course_quality_report_SJKCSL
ITEM_KEY=SJKCSL
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(distinct a.course_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                  model.major_course_record a
                  where
                  a.is_open='1'
                  and a.category = '1' and a.semester_year = '${SEMESTER_YEARS}'
                  and a.semester='${SEMESTERS}'


            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#占比（实践类课程数量/开设课程数量*100%）
function import_table_SJKCSLKCSLZB(){
#exec_dir qu_course_quality_report_SJKCSLKCSLZB
HIVE_TABLE=qu_course_quality_report_SJKCSLKCSLZB
ITEM_KEY=SJKCSLKCSLZB
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE') as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                nvl(concat(cast(count(distinct case when a.category = '1' then a.course_code end) / count(a.course_code)*100 as decimal(9,2)),'%'),0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.major_course_record a
                where
                a.is_open='1' and a.semester_year = '${SEMESTER_YEARS}'
                and a.semester='${SEMESTERS}'


            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}
#校企合作开发课程数
function import_table_XQHZKFKCS(){
#exec_dir qu_course_quality_report_XQHZKFKCS
HIVE_TABLE=qu_course_quality_report_XQHZKFKCS
ITEM_KEY=XQHZKFKCS
create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                  concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.course_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.major_course_record a
                  where a.semester_year = '${SEMESTER_YEARS}'
                  and a.semester='${SEMESTERS}'
                  and a.is_corporate_development='1'
                  and a.is_open='1'

            "
    fn_log "导入数据 —— 课程层面质量报告 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}


#课程层面规划总数
function import_table_GHZS() {
#exec_dir qu_course_quality_report_GHZS
ITEM_KEY=GHZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(0)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where a.plan_layer = 'COURSE' and a.status = 'NORMAL' and
            a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 课程层面规划总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}
#已完成规划数量
function import_table_YWCGHSL() {
#exec_dir qu_teacher_quality_YWCGHSL
ITEM_KEY=YWCGHSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                count(0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where a.plan_layer = 'COURSE' and a.status = 'NORMAL'
            and a.plan_status='YWC' and
            a.start_date between '${BEGIN_TIME}' and '${END_TIME}'

            "
    fn_log "导入数据 —— 已完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"


}

#未完成规划数量
function import_table_WWCGHSL() {
#exec_dir qu_teacher_quality_WWCGHSL
ITEM_KEY=WWCGHSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(0)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            where a.plan_layer = 'COURSE' and status = 'NORMAL'
            and a.plan_status != 'YWC' and
            a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 未完成规划数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

}
#共完成任务数量
function import_table_YWCRWSL() {
exec_dir qu_teacher_quality_GWCRWSL
ITEM_KEY=YWCRWSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(b.task_no) as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            pm_college_plan_info a
            left join
            tm_task_info b
            on a.plan_no = b.plan_no
            where a.plan_layer = 'COURSE' and
            b.task_status = 'YWC' and
            b.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 共完成任务数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}
#课程层面规划任务总数
function import_table_JSCMGHRSZS() {
#exec_dir qu_teacher_quality_JSCMGHRSZS
ITEM_KEY=JSCMGHRSZS
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(a.task_no)   as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                tm_task_info a
                left join
                pm_college_plan_info b
                on a.plan_no=b.plan_no
                where  a.task_type = 'GHRW' and
                b.plan_layer = 'COURSE' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 课程层面规划任务总数 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

#规划任务完成率  已完成课程层面规划任务总数/课程层面规划任务总数*100%
function import_table_GHRWWCL() {
#exec_dir qu_teacher_quality_GHRWWCL
ITEM_KEY=GHRWWCL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
        INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 case when count(a.task_no)=0 then 0 else
                 CONCAT(cast((count(case when a.task_status='YWC' then a.task_no end) /
                 count(a.task_no))*100 as decimal(9,2)),'%') end as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                tm_task_info a
                left join
                pm_college_plan_info b
                on a.plan_no=b.plan_no
                where  a.task_type = 'GHRW' and
                b.plan_layer = 'COURSE' and b.status='NORMAL'
                and a.start_date between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 规划任务完成率 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"



}
#课程层面质控点数量
function import_table_ZKDSL() {
#exec_dir qu_major_quality_ZKDSL
ITEM_KEY=ZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                concat('${SEMESTER_YEARS}','${SEMESTER}','STUDENT')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 count(quality_no)  as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               im_quality_info
               where index_layer = 'COURSE'
               and create_time between '${BEGIN_TIME}' and '${END_TIME}'
            "
    fn_log "导入数据 —— 课程层面质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

#目标达成率超过90%的质控点数量
function import_table_MBDCLCGBFZJSZKDSL() {
#exec_dir qu_major_quality_MBDCLCGBFZJSZKDSL
ITEM_KEY=MBDCLCGBFZJSZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.num as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (
                select
                count(a.quality_no) as num
                from
                im_course_target_standard_record a
                where
                a.is_target='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a
            "
    fn_log "导入数据 —— 目标达成率超过90%的质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

#标准达成率超过90%的质控点数量
function import_table_BZDCLCGBFZJSZKDSL() {
#exec_dir qu_major_quality_BZDCLCGBFZJSZKDSL
ITEM_KEY=BZDCLCGBFZJSZKDSL
clear_mysql_data "delete from ${TARGET_TABLE} where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}';"
find_mysql_data "
         INSERT INTO  ${TARGET_TABLE}
         (report_no,semester_year,item_key,item_value,create_time)
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}','COURSE')  as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${ITEM_KEY}' as item_key,
                 a.num as item_value,
                 FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (
                select
                count(a.quality_no) as num
                from
                im_course_target_standard_record a
                where
                a.is_standard='YES' and a.semester_year='${SEMESTER_YEARS}'
             ) a
            "
    fn_log "导入数据 —— 标准达成率超过90%的质控点数量 ${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}


#近两年的数据
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
        #开设课程数量
        import_table_KSKCSL
        #理论类课程数量
        import_table_LLLKCSL
        #占比(理论类课程数量/开设课程数量*100%)
        import_table_LLLCCSLKSKCSLZB
        #理论+实践类课程数量
        import_table_LLJSJLCSL
        #占比(理论+实践类课程数量/开设课程数量*100%)
        import_table_LLJSJLCSLKCSLZB
        #实践类课程数量
        import_table_SJKCSL
        #占比（实践类课程数量/开设课程数量*100%）
        import_table_SJKCSLKCSLZB
        #校企合作开发课程数
        import_table_XQHZKFKCS
      done
    done
}
#最新时间的一条数据
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
         #开始依次执行
        #开设课程数量
        import_table_KSKCSL
        #理论类课程数量
        import_table_LLLKCSL
        #占比(理论类课程数量/开设课程数量*100%)
        import_table_LLLCCSLKSKCSLZB
        #理论+实践类课程数量
        import_table_LLJSJLCSL
        #占比(理论+实践类课程数量/开设课程数量*100%)
        import_table_LLJSJLCSLKCSLZB
        #实践类课程数量
        import_table_SJKCSL
        #占比（实践类课程数量/开设课程数量*100%）
        import_table_SJKCSLKCSLZB
        #校企合作开发课程数
        import_table_XQHZKFKCS
    fi

}
#规划
function plan_getYearData() {
    find_mysql_data "
    select semester_year,semester,date_format(DATE_FORMAT(begin_time,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') as begin_time,
	 date_format(DATE_FORMAT(end_time,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') as end_time
	 from base_school_calendar_info where FROM_UNIXTIME(UNIX_TIMESTAMP()) BETWEEN  begin_time and end_time;"| while read -a row
    do
      SEMESTER_YEARS=${row[0]}
      SEMESTERS=${row[1]}
      BEGIN_TIME=${row[2]}
      END_TIME=${row[3]}
      if [ ! -n "$SEMESTER_YEARS" ]; then
         echo "SEMESTER_YEAR IS NULL!"
      else
         echo "SEMESTER_YEAR IS NOT NULL"
         echo ${SEMESTER_YEARS}"=="${SEMESTERS}"=="${BEGIN_TIME}"=="${END_TIME}
        #课程层面规划总数
         import_table_GHZS
         #已完成规划数量
        import_table_YWCGHSL
        #未完成规划数量
        import_table_WWCGHSL
        #共完成任务数量
        import_table_YWCRWSL
        #课程层面规划任务总数
        import_table_JSCMGHRSZS
        #规划任务完成率
        import_table_GHRWWCL
        #课程层面质控点数量
        import_table_ZKDSL
        #目标达成率超过90%的质控点数量
        import_table_MBDCLCGBFZJSZKDSL
        #标准达成率超过90%的质控点数量
        import_table_BZDCLCGBFZJSZKDSL
    fi
    done
}

#第一次调用"getYearData"将五横数据项近2年的1，2学期数据导入结果表中
#第一次调用"plan_getYearData"执行规划数据将最新数据导入结果集中
#第二次+以后执行"select_semester_year"/"plan_getYearData"
RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
getYearData >> ${RUNLOG} 2>&1
select_semester_year >> ${RUNLOG} 2>&1
plan_getYearData >> ${RUNLOG} 2>&1
finish

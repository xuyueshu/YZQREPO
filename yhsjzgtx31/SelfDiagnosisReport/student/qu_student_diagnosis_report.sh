#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir  qu_student_diagnosis_report

HIVE_DB=assurance
TARGET_TABLE=qu_student_diagnosis_report


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期学生编号(关联表 qu_student_diagnosis_report_record)',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                semester String comment '学期 1 第一学期 2 第二学期',
                student_no String comment '学生编号',
                student_name String comment '学生姓名',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '学生诊断报告信息表_${ITEM_KEY}'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "delete from qu_student_diagnosis_report where item_key = '${ITEM_KEY}'
    and substr(report_no,1,9)='${SEMESTER_YEARS}' and substr(report_no,10,1)='${SEMESTERS}' ;"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,semester,student_no,student_name,item_key,item_value,create_time'
    fn_log "导出数据--学生诊断报告信息表_${ITEM_KEY}:${HIVE_DB}.${TARGET_TABLE}"
}
#籍贯
function import_table_JG() {
#   exec_dir qu_student_diagnosis_report_JG
   HIVE_TABLE=qu_student_diagnosis_report_JG
   ITEM_KEY=JG
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 b.native_place as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            app.basic_semester_student_info a left join  model.basic_student_info b
            on a.code=b.code
            where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
            and b.native_place !=''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#民族
function import_table_MZ() {
#   exec_dir qu_student_diagnosis_report_MZ
   HIVE_TABLE=qu_student_diagnosis_report_MZ
   ITEM_KEY=MZ
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 b.ethnic as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            app.basic_semester_student_info a left join  model.basic_student_info b
            on a.code=b.code and a.major_code=b.major_code and
            a.class_code=b.class_code and a.academy_code=b.academy_code
            where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
            and b.ethnic !=''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#年级
function import_table_NJ() {
#   exec_dir qu_student_diagnosis_report_NJ
   HIVE_TABLE=qu_student_diagnosis_report_NJ
   ITEM_KEY=NJ
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 b.grade as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            app.basic_semester_student_info a left join  model.basic_student_info b
            on a.code=b.code and a.major_code=b.major_code and
            a.class_code=b.class_code and a.academy_code=b.academy_code
            where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
            and b.grade !=''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#所属系部名称
function import_table_SSXBMC() {
#   exec_dir qu_student_diagnosis_report_SSXBMC
   HIVE_TABLE=qu_student_diagnosis_report_SSXBMC
   ITEM_KEY=SSXBMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 a.academy_name as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            app.basic_semester_student_info a
            left join  model.basic_student_info b
            on a.code=b.code and a.major_code=b.major_code and
            a.class_code=b.class_code and a.academy_code=b.academy_code
            where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
            and b.academy_code != ''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#所属系部编号
function import_table_SSXBBH() {
#   exec_dir qu_student_diagnosis_report_SSXBBH
   HIVE_TABLE=qu_student_diagnosis_report_SSXBBH
   ITEM_KEY=SSXBBH
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 a.academy_code as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                app.basic_semester_student_info a left join model.basic_student_info b
                 on a.code=b.code and a.class_code=b.class_code and a.major_code=b.major_code
                 and a.academy_code=b.academy_code
                 where  a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
            and b.academy_code != ''

            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#专业编号
function import_table_ZYBH() {
#   exec_dir qu_student_diagnosis_report_ZYMC
   HIVE_TABLE=qu_student_diagnosis_report_ZYBH
   ITEM_KEY=ZYBH
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 a.major_code as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
             app.basic_semester_student_info a left join model.basic_student_info b
             on a.code=b.code and a.class_code=b.class_code and a.major_code=b.major_code
             and a.academy_code=b.academy_code
             where  a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
             and a.major_code != ''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#专业名称
function import_table_ZYMC() {
#   exec_dir qu_student_diagnosis_report_ZYMC
   HIVE_TABLE=qu_student_diagnosis_report_ZYMC
   ITEM_KEY=ZYMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 a.major_name as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
             app.basic_semester_student_info a left join model.basic_student_info b
             on a.code=b.code and a.class_code=b.class_code and a.major_code=b.major_code
             and a.academy_code=b.academy_code
             where  a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
             and a.major_code != ''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#班级编号
function import_table_BJBH() {
#   exec_dir qu_student_diagnosis_report_BJMC
   HIVE_TABLE=qu_student_diagnosis_report_BJBH
   ITEM_KEY=BJBH
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 a.class_code as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 app.basic_semester_student_info a left join model.basic_student_info b
                 on a.code=b.code and a.class_code=b.class_code and a.major_code=b.major_code
                 and a.academy_code=b.academy_code
                 where  a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
                 and a.class_name !=''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#班级名称
function import_table_BJMC() {
#   exec_dir qu_student_diagnosis_report_BJMC
   HIVE_TABLE=qu_student_diagnosis_report_BJMC
   ITEM_KEY=BJMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 a.class_name as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 app.basic_semester_student_info a left join model.basic_student_info b
                 on a.code=b.code and a.class_code=b.class_code and a.major_code=b.major_code
                 and a.academy_code=b.academy_code
                 where  a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
                 and a.class_name !=''
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#课程数量
function import_table_KCSL() {
#   exec_dir qu_student_diagnosis_report_KCSL
   HIVE_TABLE=qu_student_diagnosis_report_KCSL
   ITEM_KEY=KCSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 count(a.course_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               model.student_score_record a left join  model.basic_student_info b
              on a.code=b.code where a.semester_year='${SEMESTER_YEARS}' and
              a.semester='${SEMESTERS}' and a.course_code !='' and b.name != ''
              group by a.code,b.name
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#平均分 保留一位小数
function import_table_PJF() {
#   exec_dir qu_student_diagnosis_report_PJF
   HIVE_TABLE=qu_student_diagnosis_report_PJF
   ITEM_KEY=PJF
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 cast(sum(a.score) / count(a.code) as decimal(9,2)) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.student_score_record a left join  model.basic_student_info b
              on a.code=b.code where a.semester_year='${SEMESTER_YEARS}' and b.name !='' and
              a.semester='${SEMESTERS}' group by a.code,b.name
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#考试不通过数
function import_table_KSBTGS() {
#   exec_dir qu_student_diagnosis_report_KSBTGS
   HIVE_TABLE=qu_student_diagnosis_report_KSBTGS
   ITEM_KEY=KSBTGS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 count(case when a.score < 60 then a.course_code end) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.student_score_record a left join  model.basic_student_info b
              on a.code=b.code where a.semester_year='${SEMESTER_YEARS}' and
              a.semester='${SEMESTERS}' group by a.code,b.name
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}

#不通过课程名称  用、隔开
function import_table_BTGKCMC() {
#   exec_dir qu_student_diagnosis_report_BTGKCMC
   HIVE_TABLE=qu_student_diagnosis_report_BTGKCMC
   ITEM_KEY=BTGKCMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 concat_ws('、',collect_set(case when a.score<60 then a.course_name end))  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.student_score_record a left join  model.basic_student_info b
              on a.code=b.code where a.semester_year='${SEMESTER_YEARS}' and
              a.semester='${SEMESTERS}' group by a.code,b.name
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#班级排名
function import_table_BJPM() {
#   exec_dir qu_student_diagnosis_report_BJPM
   HIVE_TABLE=qu_student_diagnosis_report_BJPM
   ITEM_KEY=BJPM
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 a.name as student_name,
                '${ITEM_KEY}'as item_key,
                  row_number() over(partition by a.class_code order by a.score desc)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            (select b.code,c.name,c.class_code,sum(a.score) as score from
                model.student_score_record a left join app.basic_semester_student_info b
                on a.code=b.code  left join model.basic_student_info c on a.code=c.code
                and b.code=c.code
                where a.semester_year ='${SEMESTER_YEARS}' and  a.semester='${SEMESTERS}'
                group by b.code,c.name,c.class_code
             ) a
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#专业排名
function import_table_ZYPM() {
#   exec_dir qu_student_diagnosis_report_ZYPM
   HIVE_TABLE=qu_student_diagnosis_report_ZYPM
   ITEM_KEY=ZYPM
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 a.name as student_name,
                '${ITEM_KEY}'as item_key,
                 row_number() over(partition by a.major_code order by a.score desc)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            ( select b.code,c.name,c.major_code,sum(a.score) as score from
                  model.student_score_record a left join app.basic_semester_student_info b
                  on a.code=b.code  left join model.basic_student_info c on a.code=c.code
                  and b.code=c.code
                  where a.semester_year ='${SEMESTER_YEARS}' and  a.semester='${SEMESTERS}'
                  group by b.code,c.name,c.major_code
             ) a
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#借阅图书数量
function import_table_JYTSSL() {
#   exec_dir qu_student_diagnosis_report_JYTSSL
   HIVE_TABLE=qu_student_diagnosis_report_JYTSSL
   ITEM_KEY=JYTSSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 a.name as student_name,
                '${ITEM_KEY}'as item_key,
                 count(a.book_code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            model.teacher_student_book_lending_record a
            where a.semester_year='${SEMESTER_YEARS}' and a.code_type='1'
            group by a.code,a.name
            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#专业人数
function import_table_ZYRS() {
#   exec_dir qu_student_diagnosis_report_ZYRS
   HIVE_TABLE=qu_student_diagnosis_report_ZYRS
   ITEM_KEY=ZYRS
   create_table

   hive -e "
    create table tmp.major_ZYRS as
        select a.major_code ,count(a.code) as num from  app.basic_semester_student_info a
                where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
                group by a.major_code
   "
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 b.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                  c.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                app.basic_semester_student_info a left join model.basic_student_info b
                on a.code=b.code and a.major_code=b.major_code and
                a.class_code=b.class_code and a.academy_code=b.academy_code
                left join
                tmp.major_ZYRS c
                where a.major_code = c.major_code and
                a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'


            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    hive -e "
    drop table tmp.major_ZYRS
    "
    export_table
}
#专业借阅图书名次
function import_table_ZYJYTSMC() {
#   exec_dir qu_student_diagnosis_report_ZYJYTSMC
   HIVE_TABLE=qu_student_diagnosis_report_ZYJYTSMC
   ITEM_KEY=ZYJYTSMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',b.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 b.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                 row_number() over(partition by b.code,b.major_code order by b.num desc) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
               (
               select a.major_code,a.code,b.name,sum(a.book_borrowing_num)   as num
               from app.student_behavior_detailed a
               left join
               model.basic_student_info b
               on a.code=b.code
               where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
               group by a.major_code,a.code,b.name) b

            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"

    export_table
}

#全校学生人数
function import_table_QXXSRS() {
#   exec_dir qu_student_diagnosis_report_QXXSRS
   HIVE_TABLE=qu_student_diagnosis_report_QXXSRS
   ITEM_KEY=QXXSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 b.code as student_no,
                 b.name as student_name,
                '${ITEM_KEY}'as item_key,
                  c.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                app.basic_semester_student_info a left join model.basic_student_info b
                on a.code=b.code and a.major_code=b.major_code and
                a.class_code=b.class_code and a.academy_code=b.academy_code
                left join (
                select  count(a.code) as num from app.basic_semester_student_info a
                where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}') c
                where a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'

            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#全校借阅图书名次
function import_table_QXJYTSMC() {
#   exec_dir qu_student_diagnosis_report_QXJYTSMC
   HIVE_TABLE=qu_student_diagnosis_report_QXJYTSMC
   ITEM_KEY=QXJYTSMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as student_no,
                 a.name as student_name,
                '${ITEM_KEY}'as item_key,
                 ROW_NUMBER() over(partition by a.code order by a.num desc)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                (
                 select
                 a.code,
                 b.name,
                 sum(a.book_borrowing_num) as num
                 from
                 app.student_behavior_detailed a left join
                 model.basic_student_info b
                 on a.code=b.code
                 where
                 a.semester_year='${SEMESTER_YEARS}' and a.semester='${SEMESTERS}'
                 group by a.code,
                 b.name
                 ) a

            "
    fn_log "导入数据 —— 学生诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
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
         #籍贯
        import_table_JG>> ${RUNLOG} 2>&1
        #民族
        import_table_MZ >> ${RUNLOG} 2>&1
        #年级
        import_table_NJ >> ${RUNLOG} 2>&1
        #所属系部名称
        import_table_SSXBMC >> ${RUNLOG} 2>&1
        #所属系部编号
        import_table_SSXBBH >> ${RUNLOG} 2>&1
        #专业编号
        import_table_ZYBH >> ${RUNLOG} 2>&1
        #专业名称
        import_table_ZYMC >> ${RUNLOG} 2>&1
        #班级编号
        import_table_BJBH >> ${RUNLOG} 2>&1
        #班级名称
        import_table_BJMC >> ${RUNLOG} 2>&1
        #课程数量
        import_table_KCSL >> ${RUNLOG} 2>&1
        #平均分
        import_table_PJF >> ${RUNLOG} 2>&1
        #考试不通过数
        import_table_KSBTGS >> ${RUNLOG} 2>&1
        #不通过课程名称
        import_table_BTGKCMC >> ${RUNLOG} 2>&1
        #班级排名
        import_table_BJPM >> ${RUNLOG} 2>&1
        #专业排名
        import_table_ZYPM >> ${RUNLOG} 2>&1
        #借阅图书数量
        import_table_JYTSSL >> ${RUNLOG} 2>&1
        #专业人数
        import_table_ZYRS >> ${RUNLOG} 2>&1
        #专业借阅图书名次
        import_table_ZYJYTSMC >> ${RUNLOG} 2>&1
        #全校学生人数
        import_table_QXXSRS >> ${RUNLOG} 2>&1
        #全校借阅图书名次
       import_table_QXJYTSMC >> ${RUNLOG} 2>&1


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

        #开始依次执行
         #籍贯
        import_table_JG>> ${RUNLOG} 2>&1
        #民族
        import_table_MZ >> ${RUNLOG} 2>&1
        #年级
        import_table_NJ >> ${RUNLOG} 2>&1
        #所属系部名称
        import_table_SSXBMC >> ${RUNLOG} 2>&1
        #所属系部编号
        import_table_SSXBBH >> ${RUNLOG} 2>&1
        #专业编号
        import_table_ZYBH >> ${RUNLOG} 2>&1
        #专业名称
        import_table_ZYMC >> ${RUNLOG} 2>&1
        #班级编号
        import_table_BJBH >> ${RUNLOG} 2>&1
        #班级名称
        import_table_BJMC >> ${RUNLOG} 2>&1
        #课程数量
        import_table_KCSL >> ${RUNLOG} 2>&1
        #平均分
        import_table_PJF >> ${RUNLOG} 2>&1
        #考试不通过数
        import_table_KSBTGS >> ${RUNLOG} 2>&1
        #不通过课程名称
        import_table_BTGKCMC >> ${RUNLOG} 2>&1
        #班级排名
        import_table_BJPM >> ${RUNLOG} 2>&1
        #专业排名
        import_table_ZYPM >> ${RUNLOG} 2>&1
        #借阅图书数量
        import_table_JYTSSL >> ${RUNLOG} 2>&1
        #专业人数
        import_table_ZYRS >> ${RUNLOG} 2>&1
        #专业借阅图书名次
        import_table_ZYJYTSMC >> ${RUNLOG} 2>&1
        #全校学生人数
        import_table_QXXSRS >> ${RUNLOG} 2>&1
        #全校借阅图书名次
       import_table_QXJYTSMC >> ${RUNLOG} 2>&1

      done
    done
}
RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
#最新数据
select_semester_year >> ${RUNLOG} 2>&1
#近两年数据执行
#getYearData>> ${RUNLOG} 2>&1
finish



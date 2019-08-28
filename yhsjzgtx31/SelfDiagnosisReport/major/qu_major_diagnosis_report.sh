#!/bin/sh
cd `dirname $0`
source ../config.sh
exec_dir qu_major_diagnosis_report

HIVE_DB=assurance
TARGET_TABLE=qu_major_diagnosis_report


function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                report_no String comment '报告编号  格式：格式：学年学期专业编号（关联qu_major_diagnosis_report_record）',
                semester_year  String comment '学年 格式： yyyy-yyyy',
                semester String comment '学期 1 第一学期 2 第二学期',
                major_no String comment '专业编号',
                major_name String comment '专业姓名',
                item_key String comment '数据项标识',
                item_value String comment '数据值',
                create_time String comment '创建时间'
    ) COMMENT '专业诊断报告信息表_${ITEM_KEY}'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——专业诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "delete from qu_major_diagnosis_report where item_key = '${ITEM_KEY}'
    and semester_year='${SEMESTER_YEARS}' and semester='${SEMESTERS}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'report_no,semester_year,semester,major_no,major_name,item_key,item_value,create_time'
    fn_log "导出数据--专业诊断报告信息表_${ITEM_KEY}:${HIVE_DB}.${TARGET_TABLE}"
}
#所属系部名称 3年制
function import_table_SSXBMC() {
#   exec_dir qu_major_diagnosis_report_SSXBMC
   HIVE_TABLE=qu_major_diagnosis_report_SSXBMC
   ITEM_KEY=SSXBMC
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code) as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 a.academy_name as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a
                where a.semester_year = '${SEMESTER_YEARS}' and a.educational_system='3年制'
            "
    fn_log "导入数据 —— 所属系部名称${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#是否现代学徒制专业 是  否
function import_table_SFXDXTZZY() {
#   exec_dir qu_major_diagnosis_report_SFXDXTZZY
   HIVE_TABLE=qu_major_diagnosis_report_SFXDXTZZY
   ITEM_KEY=SFXDXTZZY
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 case when  b.num > 0 then '是' else '否' end  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
              model.basic_major_info a
              left join
              (
               select
               major_code,
               count(case when type='2' then major_code end ) as num
               from
               app.major_plan_student
               where semester_year = '${SEMESTER_YEARS}'
               group by major_code
               ) b
               on a.code=b.major_code
               where a.semester_year = '${SEMESTER_YEARS}' and a.educational_system='3年制'

            "
    fn_log "导入数据 —— 是否现代学徒制专业${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#设置时间  格式：yyyymmdd
function import_table_SZSJ() {
#   exec_dir qu_major_diagnosis_report_SZSJ
   HIVE_TABLE=qu_major_diagnosis_report_SZSJ
   ITEM_KEY=SZSJ
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 a.create_time  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a
                where a.semester_year = '${SEMESTER_YEARS}' and a.educational_system='3年制'
            "
    fn_log "导入数据 —— 设置时间${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#该专业班级数量
function import_table_GZYBJSL() {
#   exec_dir qu_major_diagnosis_report_GZYBJSL
   HIVE_TABLE=qu_major_diagnosis_report_GZYBJSL
   ITEM_KEY=GZYBJSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 b.num  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a
              left join
              (
               select
               major_code,
               count(code) as num
               from
               model.basic_class_info
               where grade between substr('${SEMESTER_YEARS}',1,4) and substr('${SEMESTER_YEARS}',6,4)
               group by major_code
               ) b
               on a.code=b.major_code
               where a.semester_year = '${SEMESTER_YEARS}' and a.educational_system='3年制'
            "
    fn_log "导入数据 —— 该专业班级数量${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#专业带头人姓名
function import_table_ZYDTRXM() {
#   exec_dir qu_major_diagnosis_report_ZYDTRXM
   HIVE_TABLE=qu_major_diagnosis_report_ZYDTRXM
   ITEM_KEY=ZYDTRXM
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                distinct
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 b.name  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a
                left join
                (
                    select
                    major_code,
                    concat_ws('、',collect_set(name)) as name
                    from
                    model.basic_teacher_info
                    where semester_year= '${SEMESTER_YEARS}'
                    and is_major_leader='1'
                    group by major_code
                ) b
                on a.code=b.major_code
                where a.semester_year = '${SEMESTER_YEARS}' and a.educational_system='3年制' and b.name !=''
            "
    fn_log "导入数据 —— 专业带头人姓名${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#专业学生人数
function import_table_ZYXSRS() {
#   exec_dir qu_major_diagnosis_report_ZYXSRS
   HIVE_TABLE=qu_major_diagnosis_report_ZYXSRS
   ITEM_KEY=ZYXSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                app.basic_semester_student_info b
                on a.code=b.major_code
                where a.semester_year= '${SEMESTER_YEARS}'
                and  a.educational_system='3年制'
                group by a.code,a.name
            "
    fn_log "导入数据 —— 专业诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#现有专任教师人数
function import_table_XYZRJSRS() {
#   exec_dir qu_major_diagnosis_report_XYZRJSRS
   HIVE_TABLE=qu_major_diagnosis_report_XYZRJSRS
   ITEM_KEY=XYZRJSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                model.basic_teacher_info b
                on a.code=b.major_code and a.academy_code=b.academy_code
                where a.semester_year= '${SEMESTER_YEARS}'
                and b.teacher_type ='校内专任教师'
                and  a.educational_system='3年制'
                group by a.code,a.name
            "
    fn_log "导入数据 —— 现有专任教师人数${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#生师比
function import_table_SSB() {
#   exec_dir qu_major_diagnosis_report_SSB
   HIVE_TABLE=qu_major_diagnosis_report_SSB
   ITEM_KEY=SSB
   create_table
   hive -e "
            create table tmp.student_SSB as
                select  b.major_code, count(b.code) as nums from
                    app.basic_semester_student_info b
                    where b.semester_year = '${SEMESTER_YEARS}' and b.semester ='${SEMESTERS}'
                    group by b.major_code

   "
   hive -e "
            create table tmp.teacher_SSB_one as
                select b.major_code,
                        count(b.code) as num
                        from
                        model.basic_teacher_info b
                        where b.semester_year = '${SEMESTER_YEARS}'
                        group by b.major_code

   "
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 nvl(concat(c.nums,':',d.num),0)  as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                tmp.student_SSB c
                on a.code=c.major_code
                left join
                tmp.teacher_SSB_one d
                on a.code=d.major_code
                where a.semester_year =  '${SEMESTER_YEARS}'
                and  a.educational_system='3年制'
            "
    fn_log "导入数据 —— 生师比${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table

    hive -e "
    drop table tmp.student_SSB;
    drop table tmp.teacher_SSB_one;
    "
}

#博士研究生学历教师人数
function import_table_BSYJSXLJSRS() {
#   exec_dir qu_major_diagnosis_report_BSYJSXLJSRS
   HIVE_TABLE=qu_major_diagnosis_report_BSYJSXLJSRS
   ITEM_KEY=BSYJSXLJSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                model.basic_teacher_info b
                on a.code=b.major_code and a.academy_code=b.academy_code
                where a.semester_year =  '${SEMESTER_YEARS}'
                and b.education like '%博士%'
                and a.educational_system='3年制'
                group by a.code,a.name
            "
    fn_log "导入数据 —— 博士研究生学历教师人数_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#硕士学历教师人数
function import_table_SSXLJSRS() {
#   exec_dir qu_major_diagnosis_report_SSXLJSRS
   HIVE_TABLE=qu_major_diagnosis_report_SSXLJSRS
   ITEM_KEY=SSXLJSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                model.basic_teacher_info b
                on a.code=b.major_code and a.academy_code=b.academy_code
                 where a.semester_year =  '${SEMESTER_YEARS}'
                and b.education like '%硕士%'
                and a.educational_system='3年制'
                group by a.code,a.name
            "
    fn_log "导入数据 —— 硕士学历教师人数_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#本专业高级职称教师人数
function import_table_BZYGJZCJSRS() {
#   exec_dir qu_major_diagnosis_report_BZYGJZCJSRS
   HIVE_TABLE=qu_major_diagnosis_report_BZYGJZCJSRS
   ITEM_KEY=BZYGJZCJSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                model.basic_teacher_info b
                on a.code=b.major_code and a.academy_code=b.academy_code
                 where a.semester_year =  '${SEMESTER_YEARS}'
                and b.professional_title_level like '%高%'
                and a.educational_system='3年制'
                group by a.code,a.name

            "
    fn_log "导入数据 —— 专业诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#本专业双师素质教师人数
function import_table_BZYSSSZJSRS() {
#   exec_dir qu_major_diagnosis_report_BZYSSSZJSRS
   HIVE_TABLE=qu_major_diagnosis_report_BZYSSSZJSRS
   ITEM_KEY=BZYSSSZJSRS
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.code as major_no,
                 a.name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_major_info a left join
                model.basic_teacher_info b
                on a.code=b.major_code and a.academy_code=b.academy_code
                where a.semester_year = '${SEMESTER_YEARS}'
                and b.is_double_professionally ='1'
                and a.educational_system='3年制'
                group by a.code,a.name

            "
    fn_log "导入数据 —— 本专业双师素质教师人数_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#本专业著作数量
function import_table_BZY() {
#   exec_dir qu_major_diagnosis_report_BZY
   HIVE_TABLE=qu_major_diagnosis_report_BZY
   ITEM_KEY=BZY
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_teacher_info a left join
                model.scientific_work_personnel_info b
                on a.code=b.teacher_code
                where a.semester_year =  '${SEMESTER_YEARS}' and a.major_code !=''
                group by a.major_code,a.major_name

            "
    fn_log "导入数据 —— 本专业著作数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#独立发表论文数量
function import_table_DLFBLWSL() {
#   exec_dir qu_major_diagnosis_report_DLFBLWSL
   HIVE_TABLE=qu_major_diagnosis_report_DLFBLWSL
   ITEM_KEY=DLFBLWSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.first_author_code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_teacher_info a left join
                model.scientific_paper_basic_info b
                on a.code=b.first_author_code
                where b.semester_year =  '${SEMESTER_YEARS}' and a.major_code!=''
                group by a.major_code,a.major_name

            "
    fn_log "导入数据 —— 独立发表论文数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#论文作者包含本校教师的论文数量
function import_table_LWZZBHBXJSDLWSL() {
#   exec_dir qu_major_diagnosis_report_LWZZBHBXJSDLWSL
   HIVE_TABLE=qu_major_diagnosis_report_LWZZBHBXJSDLWSL
   ITEM_KEY=LWZZBHBXJSDLWSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                 '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                model.basic_teacher_info a,
                model.scientific_paper_basic_info b
                where a.code=b.first_author_code
                and  b.semester_year =  '${SEMESTER_YEARS}' and a.major_code != ''
                group by a.major_code,a.major_name
            "
    fn_log "导入数据 —— 论文作者包含本校教师的论文数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#获奖项目数量
function import_table_HJXMSL() {
#  exec_dir qu_major_diagnosis_report_HJXMSL
   HIVE_TABLE=qu_major_diagnosis_report_HJXMSL
   ITEM_KEY=HJXMSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            model.basic_teacher_info a
            left join
            model.scientific_award_result_info b
            on b.first_author_code = b.code
            where a.semester_year = '${SEMESTER_YEARS}'
            and b.semester_year = '${SEMESTER_YEARS}'
            group by a.major_code,a.major_name
            "
    fn_log "导入数据 —— 获奖项目数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#国家级获奖项目数量
function import_table_GJJHJXMSL() {
#   exec_dir qu_major_diagnosis_report_GJJHJXMSL
   HIVE_TABLE=qu_major_diagnosis_report_GJJHJXMSL
   ITEM_KEY=GJJHJXMSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
           select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            model.basic_teacher_info a
            left join
            model.scientific_award_result_info b
            on b.first_author_code = b.code
            where a.semester_year = '${SEMESTER_YEARS}'
            and b.semester_year = '${SEMESTER_YEARS}'
            and b.level='国家级'
            group by a.major_code,a.major_name
            "
    fn_log "导入数据 —— 国家级获奖项目数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#省级获奖项目数量
function import_table_SJHJXMSL() {
#   exec_dir qu_major_diagnosis_report_SJHJXMSL
   HIVE_TABLE=qu_major_diagnosis_report_SJHJXMSL
   ITEM_KEY=SJHJXMSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code)as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            model.basic_teacher_info a
            left join
            model.scientific_award_result_info b
            on b.first_author_code = b.code
            where a.semester_year = '${SEMESTER_YEARS}'
            and b.semester_year = '${SEMESTER_YEARS}'
            and b.level='省部级'
            group by a.major_code,a.major_name
            "
    fn_log "导入数据 —— 省级获奖项目数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#地市级获奖项目数量
function import_table_SSJHJXMSL() {
#   exec_dir qu_major_diagnosis_report_SSJHJXMSL
   HIVE_TABLE=qu_major_diagnosis_report_SSJHJXMSL
   ITEM_KEY=SSJHJXMSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code) as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            model.basic_teacher_info a
            left join
            model.scientific_award_result_info b
            on b.first_author_code = b.code
            where a.semester_year = '${SEMESTER_YEARS}'
            and b.semester_year = '${SEMESTER_YEARS}'
            and b.level='市级'
            group by a.major_code,a.major_name
            "
    fn_log "导入数据 —— 地市级获奖项目数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#校级获奖项目数量
function import_table_XJHJXMSL() {
#   exec_dir qu_major_diagnosis_report_XJHJXMSL
   HIVE_TABLE=qu_major_diagnosis_report_XJHJXMSL
   ITEM_KEY=XJHJXMSL
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',a.major_code) as report_no,
                 '${SEMESTER_YEARS}' as semester_year,
                  '${SEMESTERS}' as semester,
                 a.major_code as major_no,
                 a.major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 count(b.code) as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
            model.basic_teacher_info a
            left join
            model.scientific_award_result_info b
            on b.first_author_code = b.code
            where a.semester_year = '${SEMESTER_YEARS}'
            and b.semester_year = '${SEMESTER_YEARS}'
            and b.level='校级'
            group by a.major_code,a.major_name
            "
    fn_log "导入数据 —— 校级获奖项目数量_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
    export_table
}
#专业带头人编号
function Professional_leader_no() {
#   exec_dir Professional_leader_no
   HIVE_TABLE=Professional_leader_no
   ITEM_KEY=ZYDTRBH
   create_table
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
              select
                 concat('${SEMESTER_YEARS}','${SEMESTERS}',major_code) as report_no,
                '${SEMESTER_YEARS}' as semester_year,
                '${SEMESTERS}'as semester,
                 major_code as major_no,
                 major_name as major_name,
                '${ITEM_KEY}'as item_key,
                 code as item_value,
                FROM_UNIXTIME(UNIX_TIMESTAMP()) AS create_time
            from
                 model.basic_teacher_info
                 where semester_year= '${SEMESTER_YEARS}'
                 and is_major_leader='1'
            "
    fn_log "导入数据 —— 专业诊断报告信息表_${ITEM_KEY}：${HIVE_DB}.${HIVE_TABLE}"
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
        #所属系部名称 3年制
         import_table_SSXBMC
         #是否现代学徒制专业 是  否
         import_table_SFXDXTZZY
         #设置时间  格式：yyyymmdd
         import_table_SZSJ
         #该专业班级数量
         import_table_GZYBJSL
         #专业带头人姓名
         import_table_ZYDTRXM
        #专业学生人数
         import_table_ZYXSRS
         #现有专任教师人数
         import_table_XYZRJSRS
         #生师比
         import_table_SSB
         #博士研究生学历教师人数
         import_table_BSYJSXLJSRS
          #硕士学历教师人数
         import_table_SSXLJSRS
         #本专业高级职称教师人数
         import_table_BZYGJZCJSRS
         #本专业双师素质教师人数
         import_table_BZYSSSZJSRS
         #本专业著作数量
         import_table_BZY
         #论文作者包含本校教师的论文数量
         import_table_LWZZBHBXJSDLWSL
         #获奖项目数量
         import_table_HJXMSL
         #国家级获奖项目数量
         import_table_GJJHJXMSL
         #省级获奖项目数量
         import_table_SJHJXMSL
         #地市级获奖项目数量
         import_table_SSJHJXMSL
         #校级获奖项目数量
         import_table_XJHJXMSL
        #专业带头人编号
        Professional_leader_no
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
        #所属系部名称 3年制
         import_table_SSXBMC >> ${RUNLOG} 2>&1
         #是否现代学徒制专业 是  否
         import_table_SFXDXTZZY >> ${RUNLOG} 2>&1
         #设置时间  格式：yyyymmdd
         import_table_SZSJ >> ${RUNLOG} 2>&1
         #该专业班级数量
         import_table_GZYBJSL >> ${RUNLOG} 2>&1
         #专业带头人姓名
         import_table_ZYDTRXM >> ${RUNLOG} 2>&1
        #专业学生人数
         import_table_ZYXSRS >> ${RUNLOG} 2>&1
         #现有专任教师人数
         import_table_XYZRJSRS >> ${RUNLOG} 2>&1
         #生师比
         import_table_SSB >> ${RUNLOG} 2>&1
         #博士研究生学历教师人数
         import_table_BSYJSXLJSRS >> ${RUNLOG} 2>&1
          #硕士学历教师人数
         import_table_SSXLJSRS >> ${RUNLOG} 2>&1
         #本专业高级职称教师人数
         import_table_BZYGJZCJSRS >> ${RUNLOG} 2>&1
         #本专业双师素质教师人数
         import_table_BZYSSSZJSRS >> ${RUNLOG} 2>&1
         #本专业著作数量
         import_table_BZY >> ${RUNLOG} 2>&1
         #论文作者包含本校教师的论文数量
         import_table_LWZZBHBXJSDLWSL >> ${RUNLOG} 2>&1
         #获奖项目数量
         import_table_HJXMSL >> ${RUNLOG} 2>&1
         #国家级获奖项目数量
         import_table_GJJHJXMSL >> ${RUNLOG} 2>&1
         #省级获奖项目数量
         import_table_SJHJXMSL >> ${RUNLOG} 2>&1
         #地市级获奖项目数量
         import_table_SSJHJXMSL >> ${RUNLOG} 2>&1
         #校级获奖项目数量
         import_table_XJHJXMSL >> ${RUNLOG} 2>&1
        #专业带头人编号
        Professional_leader_no >> ${RUNLOG} 2>&1

      done
    done
}
RUNLOG=./logs/$0_`date +%Y-%m-%d`.log 2>&1
#最新学年学期执行
select_semester_year
#需要最近两年的学年学期数据执行
#getYearData>> ${RUNLOG} 2>&1
finish





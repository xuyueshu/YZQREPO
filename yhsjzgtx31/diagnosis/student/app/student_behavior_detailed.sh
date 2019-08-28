#!/bin/sh
##########################################################
###  基础表:       学生行为习惯明细表
###  维护人:       ZhangWeiCe
###  数据源:       model.student_disciplinary_info,model.teacher_student_book_lending_record, model.student_dormitory_sanitation
###   model.student_dormitory_sanitation,app.basic_semester_student_info

###  导入方式:      全量
###  运行命令:      sh student_behavior_detailed.sh. &
###  结果目标:      app.student_behavior_detailed
##########################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_behavior_detailed

HIVE_DB=app
HIVE_TABLE=student_behavior_detailed
TARGET_TABLE=student_behavior_detailed

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            major_code  STRING  COMMENT '专业编号',
            class_code  STRING  COMMENT '班级编号',
            code  STRING  COMMENT '学生编号',
            punishment_num INT  COMMENT '学生处分次数',
            book_borrowing_num  INT  COMMENT '学生借阅图书次数',
            night_out_num  INT  COMMENT '夜不归宿次数',
            health_disqualification_num  INT  COMMENT '宿舍卫生通报次数',
            semester  STRING  COMMENT '学期',
            semester_year  STRING  COMMENT '学年'
    ) COMMENT '学生行为习惯明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表 —— 学生行为习惯明细表：${HIVE_DB}.${HIVE_TABLE}"
}

#修改后的查询sql
function import_table_new(){


hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
SELECT
                a.major_code,
                a.class_code,
                a.code,
                nvl(c.cf,0) as punishment_num,
                '0' as book_borrowing_num,
                nvl(b.num,0) as night_out_num,
                '0' as health_disqualification_num,
                a.semester,
                a.semester_year
            FROM
                model.student_disciplinary_info a LEFT JOIN
                (select count(0) as num,class_code,major_code,code from model.student_disciplinary_info where
                dispose like '夜不归宿' GROUP BY major_code,class_code,code) b on a.code=b.code
                left join (select count(0) as cf,code from model.student_disciplinary_info where dispose_code is not null
                group by code) c on c.code=a.code
            GROUP BY
                a.major_code,a.class_code,a.code,c.cf,b.num,a.semester,a.semester_year

        "

}

function import_table() {

    hive -e "
        create table tmp.student_behavior_punishment as
            select
                major_code,
                class_code,
                code as code,
                count(code) as num,
                semester as  semester,
                semester_year as  semester_year
            FROM
              model.student_disciplinary_info
            group by
                academy_code,major_code,class_code,code,semester_year,semester;
        "

    hive -e "
        create table tmp.student_behavior_book_borrowing as
            select
                code as code,
                count(code) as num,
                semester as  semester,
                semester_year as  semester_year
            FROM
             model.teacher_student_book_lending_record
             where code_type=1
            group by
               code,semester_year,semester;
        "
    hive -e "
        create table tmp.student_behavior_health_disqualification as
             select
                code as code,
                count(code) as num,
                semester as  semester,
                semester_year as  semester_year
            FROM
             model.student_pull_tonight
            group by
               code,semester_year,semester;
        "
     hive -e "
        create table tmp.student_behavior_night_out as
             select
                code as code,
                count(code) as num,
                semester as  semester,
                semester_year as  semester_year
            FROM
             model.student_dormitory_sanitation
            group by
               code,semester_year,semester;
        "
     hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
                s.major_code as major_code,
                s.class_code as class_code,
                 s.code as code,
                if(pp.num is null,0,pp.num) as punishment_num,
                if(bb.num is null,0,bb.num) as book_borrowing_num,
                if(noo.num is null,0,noo.num) as night_out_num,
                if(hd.num is null,0,hd.num) as health_disqualification_num,
                s.semester as  semester,
                s.semester_year as  semester_year
            FROM
            app.basic_semester_student_info as s
            left join tmp.student_behavior_punishment as pp  on s.code =pp.code and pp.semester_year= s.semester_year and pp.semester=s.semester
            left join tmp.student_behavior_book_borrowing as bb  on s.code =bb.code and bb.semester_year= s.semester_year and bb.semester=s.semester
            left join tmp.student_behavior_night_out as noo  on s.code =noo.code and noo.semester_year= s.semester_year and noo.semester=s.semester
            left join tmp.student_behavior_health_disqualification as hd  on s.code =hd.code and hd.semester_year= s.semester_year and hd.semester=s.semester
        "
     hive -e "
            DROP TABLE IF EXISTS tmp.student_behavior_punishment;
            DROP TABLE IF EXISTS tmp.student_behavior_book_borrowing;
            DROP TABLE IF EXISTS tmp.student_behavior_night_out;
            DROP TABLE IF EXISTS tmp.student_behavior_health_disqualification;
     "
    fn_log "导入数据 —— 学生行为习惯明细表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'major_code,class_code,code,punishment_num,book_borrowing_num,night_out_num,health_disqualification_num,semester,semester_year'

    fn_log "导出数据--学生行为习惯明细表:${HIVE_DB}.${TARGET_TABLE}"
}


#init_exit
create_table
#import_table
import_table_new
export_table
finish



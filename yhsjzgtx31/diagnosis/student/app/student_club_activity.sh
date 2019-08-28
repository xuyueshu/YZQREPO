#!/bin/sh
###################################################
###   基础表:      学生社团活动情况表
###   维护人:      ZhangWeiCe
###   数据源:      app.basic_semester_student_info,model.student_join_community,model.student_lecture_info,model.student_social_activity

###  导入方式:      全量导入
###  运行命令:      sh student_club_activity.sh &
###  结果目标:      app.student_club_activity
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_club_activity

HIVE_DB=app
HIVE_TABLE=student_club_activity
TARGET_TABLE=student_club_activity

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        academy_code   STRING     COMMENT '系部编号',
                        major_code   STRING     COMMENT '专业编号',
                        class_code   STRING     COMMENT '班级编号',
                        code   STRING     COMMENT '学生编号',
                        club_num   STRING     COMMENT '加入社团数量',
                        chair_num   STRING     COMMENT '参加各类讲座数量',
                        activity_num   STRING     COMMENT '参加社会活动数量',
                        semester_year   STRING     COMMENT '学年',
                        semester   STRING     COMMENT '学期' )COMMENT  '学生社团活动情况表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生社团活动情况表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
           SELECT DISTINCT
            t1.academy_code,
            t1.major_code,
            t1.class_code,
            t1.CODE,
            if(t2.club_num is null,0,t2.club_num),
            if(t3.chair_num is null,0,t3.chair_num),
            if(t4.activity_num is null,0,t4.activity_num),
            t1.semester_year AS semester_year,
            t1.semester AS semester
        FROM
            app.basic_semester_student_info t1
            LEFT JOIN ( SELECT student_code, count( 1 ) AS club_num, semester_year, semester FROM model.student_join_community GROUP BY student_code, semester_year, semester ) t2 ON t1.CODE = t2.student_code
            AND t1.semester_year = t2.semester_year
            AND t1.semester = t2.semester
            LEFT JOIN ( SELECT student_code, count( 1 ) AS chair_num, semester_year, semester FROM model.student_lecture_info GROUP BY student_code, semester_year, semester ) t3 ON t1.CODE = t3.student_code
            AND t1.semester_year = t3.semester_year
            AND t1.semester = t3.semester
            LEFT JOIN ( SELECT code, count( 1 ) AS activity_num, semester_year, semester FROM model.student_social_activity GROUP BY code, semester_year, semester ) t4 ON t1.CODE = t4.code
            AND t1.semester_year = t4.semester_year
            AND t1.semester = t4.semester
        "
        fn_log " 导入数据--学生社团活动情况表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,code,club_num,chair_num,activity_num,semester_year,semester"

    fn_log "导出数据--学生社团活动情况表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
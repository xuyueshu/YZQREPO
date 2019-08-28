#!/bin/sh
##########################################################
###  基础表:       学生等级考试统计表
###  维护人:       shilp
###  数据源:       model.student_grade_test_detailed,app.basic_semester_student_info

###  导入方式:      全量
###  运行命令:      sh student_grade_examination_count.sh. &
###  结果目标:      app.student_grade_examination_count
##########################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_grade_examination_count

HIVE_DB=app
HIVE_TABLE=student_grade_examination_count
TARGET_TABLE=student_grade_examination_count

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
        academy_code STRING COMMENT '系编号',
        major_code STRING COMMENT '专业编号',
        class_code STRING COMMENT '班级编号',
        test_name STRING COMMENT '考试名称（pets4，pets6，ncre1，ncre2，ncre3）',
        num STRING COMMENT '考试总人数',
        pass_num INT COMMENT '通过人数',
        unqualified_num INT COMMENT '不合格人数',
        semester STRING COMMENT '学期',
        semester_year STRING COMMENT '学年'
    ) COMMENT '学生等级考试统计表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    exec_log "创建表 —— 学生等级考试统计表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
        SELECT
            a.academy_name,
            a.major_name,
            a.class_name,
            a.test_name,
            a.aa as num,
            IF(b.bb IS NULL,0,b.bb) as pass_num,
            IF(c.cc IS NULL,0,c.cc) as unqualified_num,
            a.semester,
            a.semester_year
        FROM
            (
                SELECT
                    bssi.academy_name,
                    bssi.major_name,
                    bssi.class_name,
                    sgtd.semester,
                    sgtd.semester_year,
                    sgtd.test_name,
                    COUNT(sgtd. CODE) AS aa
                FROM
                    model.student_grade_test_detailed sgtd left join
                    app.basic_semester_student_info bssi
                WHERE
                    sgtd.code = bssi.code
                AND sgtd.semester_year = bssi.semester_year
                AND sgtd.semester = bssi.semester
                GROUP BY
                    bssi.academy_name,
                    bssi.major_name,
                    bssi.class_name,
                    sgtd.semester,
                    sgtd.semester_year,
                    sgtd.test_name
            ) a
        LEFT JOIN (
            SELECT
                bssi.class_name,
                sgtd.semester,
                sgtd.semester_year,
                sgtd.test_name,
                COUNT(sgtd. CODE) AS bb
            FROM
                model.student_grade_test_detailed sgtd left join
                app.basic_semester_student_info bssi
            WHERE
                sgtd.code = bssi.code
            AND sgtd.semester_year = bssi.semester_year
            AND sgtd.semester = bssi.semester
            AND sgtd.score>60 or sgtd.score=60
            GROUP BY
                bssi.class_name,
                sgtd.semester,
                sgtd.semester_year,
                sgtd.test_name
        ) b ON a.class_name = b.class_name
        AND a.semester = b.semester
        AND a.semester_year = b.semester_year
        AND a.test_name = b.test_name
        LEFT JOIN (
            SELECT
                bssi.class_name,
                sgtd.semester,
                sgtd.semester_year,
                sgtd.test_name,
                COUNT(sgtd. CODE) AS cc
            FROM
                model.student_grade_test_detailed sgtd left join
                app.basic_semester_student_info bssi
            WHERE
                sgtd.code = bssi.code
            AND sgtd.semester_year = bssi.semester_year
            AND sgtd.semester = bssi.semester
            AND sgtd.score<60
            GROUP BY
                bssi.class_name,
                sgtd.semester,
                sgtd.semester_year,
                sgtd.test_name
        ) c ON a.class_name = c.class_name
        AND a.semester = c.semester
        AND a.semester_year = c.semester_year
        AND a.test_name = c.test_name
        "
    fn_log "导入数据 —— 学生等级考试统计表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'academy_code,major_code,class_code,test_name,num,pass_num,unqualified_num,semester,semester_year'

    fn_log "导出数据--学生等级考试统计表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish



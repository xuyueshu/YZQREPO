#!/bin/sh
###################################################
###   基础表:      学生平均资产统计表
###   维护人:      yangsh
###   数据源:      MODEL.college_basic_info，app.basic_semester_student_info

###  导入方式:      全量导入
###  运行命令:      sh college_assets_student_avg.sh &
###  结果目标:      app.college_assets_student_avg
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir college_assets_student_avg

HIVE_DB=app
HIVE_TABLE=college_assets_student_avg
TARGET_TABLE=college_assets_student_avg

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        land_acreage_avg   STRING     COMMENT '生均占地面积（平方米）',
                                        dormitory_acreage_avg   STRING     COMMENT '生均宿舍面积（平方米）',
                                        practice_acreage_avg   STRING     COMMENT '生均实践场所面积（平方米）',
                                        administrative_acreage_avg   STRING     COMMENT '生均行政用房面积（平方米）',
                                        practice_seat_avg   STRING     COMMENT '生均校内实践教学工位数（个）',
                                        pc_num_hundred_avg   STRING     COMMENT '百名学生配教学用计算机数（台）',
                                        multimedia_seat_hundred_avg   STRING     COMMENT '百名学生配多媒体教室座位数（个）',
                                        book_avg   STRING     COMMENT '生均图书数量（册）',
                                        scientific_instrument_total   STRING     COMMENT '生均教学科研仪器设备值（元）',
                                        assets_total   STRING     COMMENT '学校总资产',
                                        semester_year   STRING     COMMENT '学年'
                                        )COMMENT  '学生平均资产统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生平均资产统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
        IF ((A.area_covered*666.667/B.STU_NUM) IS NULL,0,A.area_covered*666.667/B.STU_NUM) AS land_acreage_avg,
        IF ((A.dormitory_acreage/B.STU_NUM) IS NULL,0,A.dormitory_acreage/B.STU_NUM) AS dormitory_acreage_avg,
        IF ((A.practice_acreage/B.STU_NUM) IS NULL,0,A.practice_acreage/B.STU_NUM) AS practice_acreage_avg,
        IF ((A.administrative_acreage/B.STU_NUM) IS NULL,0,A.administrative_acreage/B.STU_NUM) AS administrative_acreage_avg,
        IF ((A.practice_seat/B.STU_NUM) IS NULL,0,A.practice_seat/B.STU_NUM) AS practice_seat_avg,
        IF ((A.pc_num/B.STU_NUM*100) IS NULL,0,A.pc_num/B.STU_NUM*100) AS pc_num_hundred_avg,
        IF ((A.multimedia_seat_count/B.STU_NUM*100) IS NULL,0,A.multimedia_seat_count/B.STU_NUM*100) AS multimedia_seat_hundred_avg,
        IF ((A.paper_book/B.STU_NUM) IS NULL,0,A.paper_book/B.STU_NUM) AS book_avg,
        IF ((A.scientific_instrument_total/B.STU_NUM) IS NULL,0,A.scientific_instrument_total/B.STU_NUM) AS scientific_instrument_total,
        IF (A.assets_total IS NULL,0,A.assets_total) AS assets_total,
        A.semester_year
        FROM MODEL.college_basic_info A
        LEFT JOIN
        (
            select count(distinct code) as stu_num,semester_year from app.basic_semester_student_info group by semester_year
        ) B
        ON A.semester_year=B.semester_year
        "
        fn_log " 导入数据--学生平均资产统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "land_acreage_avg,dormitory_acreage_avg,practice_acreage_avg,administrative_acreage_avg,practice_seat_avg,pc_num_hundred_avg,multimedia_seat_hundred_avg,book_avg,scientific_instrument_total,assets_total,semester_year"

    fn_log "导出数据--学生平均资产统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
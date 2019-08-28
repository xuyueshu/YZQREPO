#!/bin/sh
###################################################
###   基础表:      专业统计信息表（统计年度，新增，撤销，招生，取消）
###   维护人:      ZhangWeiCe
###   数据源:      model.basic_major_info,model.major_enroll_student

###  导入方式:      全量导入
###  运行命令:      sh major_total_info.sh &
###  结果目标:      app.major_total_info
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir major_total_info

HIVE_DB=app
HIVE_TABLE=major_total_info
TARGET_TABLE=major_total_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                enroll_student_major_count   STRING   COMMENT '招生专业个数',
                new_add_major_count   STRING   COMMENT  '新增专业个数',
                stop_recruit_major_count   STRING     COMMENT '停招专业个数',
                revocation_major_count   STRING     COMMENT '撤销专业个数',
                type   STRING     COMMENT '专业类型：1专科, 2本科',
                major_count   STRING     COMMENT '专业总数',
                semester_year   STRING     COMMENT '学年'
        )COMMENT  '专业统计信息表（统计年度，新增，撤销，招生，取消）'
       LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"
       fn_log "创建表--专业统计信息表（统计年度，新增，撤销，招生，取消）: ${HIVE_DB}.${HIVE_TABLE}"
}


function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
              nvl(zhao,0) as enroll_student_major_count,
              nvl(add_count,0) as new_add_major_count,
              nvl(stop_major,0) as stop_recruit_major_count,
              nvl(stop_count,0) as   revocation_major_count,
              t3.type,
              major_count,
              '$1'
        FROM (
            SELECT major_count,t1.semester_year,t1.type,zhao,stop_major
            FROM (
                SELECT
                    TYPE,
                    semester_year,
                    COUNT(1) major_count
                FROM  model.basic_major_info
                WHERE semester_year='$1'
                GROUP BY semester_year,TYPE
            )t1
            INNER JOIN (
                SELECT
                    semester_year,
                    TYPE,
                    SUM(CASE WHEN plan_enroll_student_count>0 THEN 1 ELSE 0 END) zhao,
                    SUM(CASE WHEN plan_enroll_student_count=0 THEN 1 ELSE 0 END) stop_major
                FROM (
                    SELECT  plan_enroll_student_count,a.semester_year,b.type
                    FROM model.major_enroll_student a
                    INNER JOIN model.basic_major_info b
                    ON a.major_code=b.code AND a.semester_year=b.semester_year
                    WHERE a.semester_year='$1'
                )a
                GROUP BY semester_year,TYPE
            ) t2
            ON t1.semester_year=t2.semester_year AND t1.type=t2.type
        ) t3
        left JOIN (
            SELECT
            semester_year,
            TYPE,
            COUNT(1) add_count
            FROM  model.basic_major_info a
            WHERE semester_year='$1'
            AND a.CODE NOT IN (
             SELECT CODE
             FROM model.basic_major_info b
             WHERE b.semester_year='$2'
            )
            GROUP BY semester_year,TYPE
        ) t4
        ON t3.semester_year=t4.semester_year AND t3.type=t4.type
        LEFT JOIN (
            SELECT
            semester_year,
            TYPE,
            COUNT(1) stop_count
            FROM  model.basic_major_info a
            WHERE semester_year='$2'
            AND a.CODE NOT IN (
             SELECT CODE
             FROM model.basic_major_info b
             WHERE b.semester_year='$1'
            )
            GROUP BY semester_year,TYPE
        )t5
        ON t3.semester_year=t5.semester_year AND t3.type=t5.type
        "
        fn_log " 导入数据--专业统计信息表（统计年度，新增，撤销，招生，取消）: ${HIVE_DB}.${HIVE_TABLE}"

}

function more_import_data(){
   semester_year=`cur_se_year_by_date`
   for((i=1;i<=10;i++));
   do
      last_year=`last_year  $semester_year`
      import_table $semester_year $last_year
      semester_year=$last_year
   done

}


function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "enroll_student_major_count,new_add_major_count,stop_recruit_major_count,revocation_major_count,type,major_count,semester_year"

    fn_log "导出数据--专业统计信息表（统计年度，新增，撤销，招生，取消）: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
more_import_data
export_table
finish
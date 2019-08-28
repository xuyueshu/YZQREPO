#!/bin/sh
#################################################
###  基础表:       学生行为习惯统计表
###  维护人:       guojianing
###  数据源:       model.student_disciplinary_info,model.student_pull_tonight,model.student_dormitory_sanitation,model.basic_class_info

###  导入方式:      全量
###  运行命令:      sh student_behavior_count.sh. &
###  结果目标:      app.student_behavior_count
#################################################

cd `dirname $0`
source ../../../config.sh
exec_dir student_behavior_count

HIVE_DB=app
HIVE_TABLE=student_behavior_count
TARGET_TABLE=student_behavior_count

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            academy_code  STRING  COMMENT '系编号',
            major_code  STRING  COMMENT '专业编号',
            class_code  STRING  COMMENT '班级编号',
            punishment_num INT  COMMENT '处分数据',
            night_out_num  INT  COMMENT '夜不归宿数量',
            health_disqualification_num  INT  COMMENT '宿舍卫生通报数量',
            semester  STRING  COMMENT '学期',
            semester_year  STRING  COMMENT '学年',
            happen_time  STRING  COMMENT '发生月份(yyyy-mm)'

    ) COMMENT '学生行为习惯统计表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表 —— 学生行为习惯统计表：${HIVE_DB}.${HIVE_TABLE}"
}

#修改后的查询sql
function import_table_new(){


hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
SELECT
                a.academy_code,
                a.major_code,
                a.class_code,
                count( 1 ) as punishment_num,
                nvl(b.num,0) as night_out_num,
                '0' as health_disqualification_num,
                a.semester,
                a.semester_year,
                from_unixtime(UNIX_TIMESTAMP(a.dispose_time, 'yyyyMMdd'),'yyyy-MM') as happen_time
            FROM
                model.student_disciplinary_info a LEFT JOIN
                (select count(0) as num,class_code,academy_code,major_code from model.student_disciplinary_info where
                dispose like '夜不归宿' and academy_code is not null and major_code is not null and class_code is not null
                GROUP BY academy_code,major_code,class_code) b on
                a.academy_code=b.academy_code and a.class_code=b.class_code and a.major_code=b.major_code
            GROUP BY
                a.academy_code,a.major_code,a.class_code,b.num,a.semester,a.semester_year,a.dispose_time

        "

}
function import_table() {
    hive -e "
        create table tmp.student_punishment_num as
            SELECT
                a.academy_code,
                a.major_code,
                a.class_code,
                count( 1 ) as punishment_num,
                a.semester,
                a.semester_year,
                from_unixtime(UNIX_TIMESTAMP(a.dispose_time, 'yyyyMMdd'),'yyyy-MM') as happen_time
            FROM
                model.student_disciplinary_info a
            GROUP BY
                a.academy_code,a.major_code,a.class_code,a.semester,a.semester_year,a.dispose_time
        "

    hive -e "
        create table tmp.student_night_out_num as
            SELECT
                academy_code,
                major_code,
                class_code,
                count(1) as night_out_num,
                semester,
                semester_year,
                from_unixtime(UNIX_TIMESTAMP(time, 'yyyyMMdd'),'yyyy-MM') AS happen_time
            FROM
                model.student_pull_tonight
            GROUP BY
                academy_code,
                major_code,
                class_code,
                semester,
                semester_year,time
        "

    hive -e "
        create table tmp.student_health_disqualification_num as
            SELECT
                academy_code,
                major_code,
                class_code,
                count( 1 ) as health_disqualification_num,
                semester,
                semester_year,
                substr( time, 1, 7 ) AS happen_time
            FROM
                model.student_dormitory_sanitation
            GROUP BY
                academy_code,
                major_code,
                class_code,
                semester,
                semester_year,time
        "

     hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
           select distinct
                 t1.academy_code,
                 t1.major_code,
                 t1.code as class_code,
                 if(t2.punishment_num is null,0,t2.punishment_num),
                 if(t3.night_out_num is null,0,t3.night_out_num),
                 if(t4.health_disqualification_num is null,0,t4.health_disqualification_num),
                 t2.semester,
                 t2.semester_year,
                 t2.happen_time
            from model.basic_class_info t1
            left join tmp.student_punishment_num t2 on t1.code=t2.major_code
            left join tmp.student_night_out_num t3 on t1.code=t3.major_code and t2.semester=t3.semester and t2.semester_year=t3.semester_year and t2.happen_time=t3.happen_time
            left join tmp.student_health_disqualification_num t4 on t1.code=t4.major_code and t2.semester=t4.semester and t2.semester_year=t4.semester_year and t2.happen_time=t4.happen_time
        "
     hive -e "
            DROP TABLE IF EXISTS tmp.student_punishment_num;
            DROP TABLE IF EXISTS tmp.student_night_out_num;
            DROP TABLE IF EXISTS tmp.student_health_disqualification_num;
     "

    fn_log "导入数据 —— 学生行为习惯统计表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'academy_code,major_code,class_code,punishment_num,night_out_num,health_disqualification_num,semester,semester_year,happen_time'

    fn_log "导出数据--学生行为习惯统计表:${HIVE_DB}.${TARGET_TABLE}"
}

#init_exit
#create_table
import_table_new
#import_table
export_table
finish



#!/bin/sh
###################################################
###   基础表:      教师工作量信息表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_workload_information_record.sh &
###  结果目标:      app.teacher_workload_information_record
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_workload_information_record

HIVE_DB=model
HIVE_TABLE=teacher_workload_information_record
TARGET_TABLE=teacher_workload_information_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        course_code   STRING     COMMENT '课程编号',
                                        course_name   STRING     COMMENT '课程名称',
                                        credit   STRING     COMMENT '学分',
                                        category   STRING     COMMENT '课程类别:0理论,1实践,2理论加实践,99其他',
                                        status   STRING     COMMENT '状态',
                                        course_number   STRING     COMMENT '课序号',
                                        total_hour   STRING     COMMENT '总学时',
                                        workload   STRING     COMMENT '教学工作量',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期'        )COMMENT  '教师工作量信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师工作量信息表: ${HIVE_DB}.${HIVE_TABLE}"
}


function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select  distinct
                aa.code code,
                aa.name name,
                aa.course_code course_code,
                aa.course_name course_name,
                b.XF credit,
                case when trim(b.KCLX)='理论课' then 0 when trim(b.KCLX)='实践课' then 1 when trim(b.KCLX)='理论+实践课' then 2 else 99 end category,
                1 status,
                aa.course_number course_number,
                aa.total_hour total_hour,
                aa.workload workload,
                aa.semester_year semester_year,
                aa.semester semester
        from
            (SELECT
                a.JSZGH code,
                a.JKJS name,
                a.KBKCDM course_code,
                a.KBKCMC course_name,
                '' course_number,
                a.ZXS total_hour,
                sum(a.ZXS) workload,
                a.KBXN semester_year,
                a.KBXQ semester
            FROM raw.zgy_t_zg_jskb a
            GROUP BY  a.JSZGH,a.JKJS,a.KBKCDM,a.KBKCMC,a.ZXS,a.KBXN,a.KBXQ
        ) aa
        LEFT JOIN raw.sw_T_ZG_KCXXB b on aa.course_code=b.KCBH and aa.semester_year=substr(b.XKKH,2,9) and aa.semester=substr(b.XKKH,12,1)
        "
        fn_log " 导入数据--教师工作量信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,course_code,course_name,credit,category,status,course_number,total_hour,workload,semester_year,semester"

    fn_log "导出数据--教师工作量信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
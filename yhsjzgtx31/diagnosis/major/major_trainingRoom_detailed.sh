#!/bin/sh
###################################################
###   基础表:      实训室信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_trainingRoom_detailed.sh &
###  结果目标:      model.major_trainingRoom_detailed
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_trainingRoom_detailed

HIVE_DB=model
HIVE_TABLE=major_trainingRoom_detailed
TARGET_TABLE=major_trainingRoom_detailed

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        training_base_id   STRING     COMMENT '实训基地代码',
                                        name   STRING     COMMENT '实训室名称',
                                        seat_num   STRING     COMMENT '工位数',
                                        area   STRING     COMMENT '面积(平方米)',
                                        device_num   STRING     COMMENT '设备数量',
                                        price_sum   STRING     COMMENT '设备总值（万元）',
                                        project_num   STRING     COMMENT '实训项目-总数（个）',
                                        dept_code   STRING     COMMENT '系代码',
                                        dept_name   STRING     COMMENT '系名称',
                                        major_code   STRING     COMMENT '专业代码',
                                        major_name   STRING     COMMENT '专业名称',
                                        plan_use_hours   STRING     COMMENT '计划使用课时',
                                        actual_use_hours   STRING     COMMENT '使用使用课时',
                                        price_avg   STRING     COMMENT '生均仪器设备总值',
                                        lab_use_rate   STRING     COMMENT '实验室使用率(%)',
                                        semester_year   STRING     COMMENT '学年',
                                        is_school   STRING     COMMENT '1：校内，2校外'        )COMMENT  '实训室信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--实训室信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}

            select
                a.SXJDBH training_base_id,
                a.SXSMC name,
                cast(a.GWGS as int) seat_num,
                nvl(ZDMJ,0) area,
                nvl(cast(b.YQSBSL as int),0) device_num,
                nvl(round(b.YQSBZ*b.YQSBSL/10000,4),0) price_sum,
                nvl(cast(d.SJSXXMS as int),0) project_num,
                nvl(c.SSXBBH,'') dept_code,
                nvl(c.SSXB,'') dept_name,
                nvl(c.SYZYDM,'') major_code,
                nvl(c.SYZY,'') major_name,
                0 plan_use_hours,
                0 actual_use_hours,
                nvl(round(b.YQSBZ*b.YQSBSL/e.stu_num,2),0) price_avg,
                0 lab_use_rate,
                a.XNMC semester_year,
                case when trim(c.XNHZXW)='校内' then 1 when trim(c.XNHZXW)='校外' then 2 else 2 end is_school
            from raw.zgy_T_ZG_SXJDSXSGLXXB a
            left join raw.zgy_T_ZG_SXYQSBXX b on a.SXSBH=b.SXSBH
            left join raw.zgy_T_ZG_XNXWSXJDXX c on a.SXJDBH=c.SXJDBH
            left join (select sum(SJSXXMS) SJSXXMS,XNMC,XQ,ZYBH from raw.zgy_T_ZG_KCSXJXXXB group by XNMC,XQ,ZYBH) d on a.XNMC=d.XNMC and a.XQMC=d.xq and c.SYZYDM=d.ZYBH
            left join (select count(code) as stu_num,semester_year,semester,major_code from app.basic_semester_student_info group by semester_year,semester,major_code) e
                on a.XNMC=e.semester_year and a.XQMC=e.semester and c.SYZYDM=e.major_code
        "
        fn_log " 导入数据--实训室信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "training_base_id,name,seat_num,area,device_num,price_sum,project_num,dept_code,dept_name,major_code,major_name,plan_use_hours,actual_use_hours,price_avg,lab_use_rate,semester_year,is_school"

    fn_log "导出数据--实训室信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
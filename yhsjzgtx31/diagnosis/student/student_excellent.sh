#!/bin/sh
###################################################
###   基础表:      优秀学生名单
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_excellent.sh &
###  结果目标:      model.student_excellent
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_excellent

HIVE_DB=app
HIVE_TABLE=student_excellent
TARGET_TABLE=student_excellent
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=$((${PRE_YEAR} - 1))"-"${PRE_YEAR}
function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                            academy_code   STRING     COMMENT '学院编号',
                            major_code   STRING     COMMENT '专业编号',
                            class_code   STRING     COMMENT '班级编号',
                            code   STRING     COMMENT '学生编号',
                            semester_year   STRING     COMMENT '学年',
                            semester   STRING     COMMENT '学期'        )COMMENT  '优秀学生名单'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--优秀学生名单: ${HIVE_DB}.${HIVE_TABLE}"
}

#学期
function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
         select
         distinct
         case when c.XBH is null then ' ' else c.XBH end  as academy_code,
         case when  b.ZYDM is null then ' ' else b.ZYDM end as major_code,
         case when b.BH is null then ' ' else b.BH end  as class_code,
         a.XH as code,
         a.XN as semester_year,
         case when a.XQ is null then 1 else a.XQ end as semester
         from
         raw.sw_T_ZG_XG_XSPJJG a
         left join
         raw.sw_t_bzks b
         on a.XH=b.XH
         left join
         raw.zgy_t_zg_zyxx c
         on b.ZYDM=c.ZYDM
         where
         a.XN='${SEMESTER_YEARS}'
        "
        fn_log " 导入数据--优秀学生名单: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,code,semester_year,semester"

    fn_log "导出数据--优秀学生名单: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
#!/bin/sh
###################################################
###   基础表:      教师教材编写人员表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_textbook_personnel_info.sh &
###  结果目标:      app.teacher_textbook_personnel_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_textbook_personnel_info

HIVE_DB=model
HIVE_TABLE=teacher_textbook_personnel_info
TARGET_TABLE=teacher_textbook_personnel_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师名称',
                                        textbook_code   STRING     COMMENT '教材编号',
                                        write_type   STRING     COMMENT '1主编，2参编',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '教师教材编写人员表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师教材编写人员表: ${HIVE_DB}.${HIVE_TABLE}"
}


function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
                nvl(a.GH,'') code,
                nvl(a.XM,'') name,
                nvl(a.JCBH,'') textbook_code,
                case when trim(a.bxlx)='主编' then 1 else 2 end write_type,
                case when a.xn is null then '' else concat(cast(substr(a.xn,1,4) as int),'-',cast(substr(a.xn,1,4) as int)+1)  end semester_year
        from raw.pm_t_jzg_kyzz a
        "
        fn_log " 导入数据--教师教材编写人员表: ${HIVE_DB}.${HIVE_TABLE}"
}



function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,textbook_code,write_type,semester_year"

    fn_log "导出数据--教师教材编写人员表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
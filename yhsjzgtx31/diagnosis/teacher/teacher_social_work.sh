#!/bin/sh
###################################################
###   基础表:      教师社会培训明细表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_social_work.sh &
###  结果目标:      app.teacher_social_work
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_social_work

HIVE_DB=model
HIVE_TABLE=teacher_social_work
TARGET_TABLE=teacher_social_work

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        teacher_code   STRING     COMMENT '教师编号',
                                        teacher_name   STRING     COMMENT '教师姓名',
                                        project_name   STRING     COMMENT '培训项目名称',
                                        company   STRING     COMMENT '单位',
                                        participants_num   STRING     COMMENT '参加人数',
                                        trainees_num   STRING     COMMENT '培训人数',
                                        project_money   STRING     COMMENT '到款额',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '教师社会培训明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师社会培训明细表: ${HIVE_DB}.${HIVE_TABLE}"
}
#t_zg_shpxxx表中缺少teacher_code，teacher_name,trainees_num
function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
       select distinct
                '' teacher_code,
                '' teacher_name,
                a.XMMC project_name,
                b.SSDW company,
                b.cjrs participants_num,
                1 trainees_num,
                nvl(a.DKJE,0) project_money,
                case when a.CJSJ is null then '' else concat(cast(substring(a.CJSJ,1,4) as int),'-',cast(substring(a.CJSJ,1,4) as int)+1) end semester_year
        from raw.ss_t_zg_shpxxx a
        left join (SELECT SSDW,xmbh,count(1) cjrs FROM raw.ss_t_zg_shpxryxx GROUP BY xmbh,SSDW) b on a.XMBH=b.xmbh

        "
        fn_log " 导入数据--教师社会培训明细表: ${HIVE_DB}.${HIVE_TABLE}"
}


function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "teacher_code,teacher_name,project_name,company,participants_num,trainees_num,project_money,semester_year"

    fn_log "导出数据--教师社会培训明细表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
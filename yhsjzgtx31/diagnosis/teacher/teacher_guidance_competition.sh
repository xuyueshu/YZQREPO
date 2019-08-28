#!/bin/sh
###################################################
###   基础表:      指导学生参加技能竞赛
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_guidance_competition.sh &
###  结果目标:      app.teacher_guidance_competition
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_guidance_competition

HIVE_DB=model
HIVE_TABLE=teacher_guidance_competition
TARGET_TABLE=teacher_guidance_competition

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        competition_name   STRING     COMMENT '竞赛名称',
                                        competition_level   STRING     COMMENT '竞赛级别',
                                        teacher_code   STRING     COMMENT '教师编号',
                                        teacher_name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '指导学生参加技能竞赛'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--指导学生参加技能竞赛: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select distinct
            nvl(a.competition_name,'') competition_name,
            nvl(a.competition_level,'') competition_level,
            nvl(a.teacher_code,'') teacher_code,
            nvl(a.teacher_name,'') teacher_name,
            nvl(a.semester_year,'') semester_year
        from(
            select XMLXMC competition_name,XMXZMC competition_level,ZDLSBH1 teacher_code,ZDLSXM1 teacher_name, XN semester_year from raw.sw_t_zg_xg_xspjjg where ZDLSBH1 is not null
            union all
            select XMLXMC competition_name,XMXZMC competition_level,ZDLSBH2 teacher_code,ZDLSXM2 teacher_name, XN semester_year from raw.sw_t_zg_xg_xspjjg where ZDLSBH2 is not null
            union all
            select XMLXMC competition_name,XMXZMC competition_level,ZDLSBH3 teacher_code,ZDLSXM3 teacher_name, XN semester_year from raw.sw_t_zg_xg_xspjjg where ZDLSBH3 is not null
            union all
            select XMLXMC competition_name,XMXZMC competition_level,ZDLSBH4 teacher_code,ZDLSXM4 teacher_name, XN semester_year from raw.sw_t_zg_xg_xspjjg where ZDLSBH4 is not null
        ) a
        "
        fn_log " 导入数据--指导学生参加技能竞赛: ${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "competition_name,competition_level,teacher_code,teacher_name,semester_year"

    fn_log "导出数据--指导学生参加技能竞赛: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
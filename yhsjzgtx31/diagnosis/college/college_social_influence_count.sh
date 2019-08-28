#!/bin/sh
###################################################
###   基础表:      学院社会影响统计表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_social_influence_count.sh &
###  结果目标:      model.college_social_influence_count
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_social_influence_count

HIVE_DB=model
HIVE_TABLE=college_social_influence_count
TARGET_TABLE=college_social_influence_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        enterprise_visit_communication_num   STRING     COMMENT '企业来访交流数量',
                                        college_visit_communication_num   STRING     COMMENT '院校来访交流数量',
                                        other_visit_communication_num   STRING     COMMENT '其他来访交流数量',
                                        media_reports_num   STRING     COMMENT '各媒体报道数量情况',
                                        media_visit_num   STRING     COMMENT '新媒体运营访问数量',
                                        province_above_prize_num   STRING     COMMENT '省级以上获奖数量',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '学院社会影响统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院社会影响统计表: ${HIVE_DB}.${HIVE_TABLE}"
}
#新媒体运营访问数量没数据
function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select
                a.lfsl enterprise_visit_communication_num,
                b.lfsl college_visit_communication_num,
                c.lfsl other_visit_communication_num,
                d.bdsl media_reports_num,
                0 media_visit_num,
                e.hjsl province_above_prize_num,
                a.semester_year semester_year
            from(
            select  '${semester}'semester_year , count(1) lfsl
            FROM raw.ss_t_zg_lfjlxx
            where trim(LB)='企业'
            and cast(substr(LFSJ,1,4) as int)='${NOW_YEAR}' ) a

            left join

            (select  '${semester}'semester_year , count(1) lfsl
            FROM raw.ss_t_zg_lfjlxx
            where trim(LB)='学校'
            and cast(substr(LFSJ,1,4) as int)='${NOW_YEAR}' ) b on a.semester_year=b.semester_year

             left join

            (select  '${semester}'semester_year , count(1) lfsl
            FROM raw.ss_t_zg_lfjlxx
            where trim(LB)='其他'
            and cast(substr(LFSJ,1,4) as int)='${NOW_YEAR}' ) c on a.semester_year=c.semester_year

            left join

            ( select  '${semester}'semester_year , count(1) bdsl
            FROM raw.zgy_t_zg_mtbdqkb
            where cast(substr(BDSJ,1,4) as int)='${NOW_YEAR}'  ) d on a.semester_year=d.semester_year

              left join

            ( select  '${semester}'semester_year , count(1) hjsl
            FROM raw.pm_t_jzg_hjxx
            where XN ='${NOW_YEAR}'
            and (trim(HJJB)='国家级' or trim(HJJB)='省级')  ) e on a.semester_year=e.semester_year

        "
        fn_log " 导入数据--学院社会影响统计表: ${HIVE_DB}.${HIVE_TABLE}"

}



function export_table(){
   clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year = '${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "enterprise_visit_communication_num,college_visit_communication_num,other_visit_communication_num,media_reports_num,media_visit_num,province_above_prize_num,semester_year"

    fn_log "导出数据--学院社会影响统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    years=5
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
      export_table
    done
}

init_exit
create_table
getYearData
#export_table
finish
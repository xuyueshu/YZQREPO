#!/bin/sh
###################################################
###   基础表:      学院科研工作统计表
###   维护人:      yangsh
###   数据源:      model.basic_semester_info,model.scientific_award_result_info,model.scientific_project_funds_info,model.scientific_project_basic_info
###               model.scientific_team_info,model.scientific_paper_basic_info,model.scientific_patent_achievements

###  导入方式:      全量导入
###  运行命令:      sh college_scientific_count.sh &
###  结果目标:      app.college_scientific_count
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir college_scientific_count

HIVE_DB=app
HIVE_TABLE=college_scientific_count
TARGET_TABLE=college_scientific_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        semester_year   STRING     COMMENT '学年',
                                        prize_winning_num   STRING     COMMENT '科研获奖数量',
                                        prize_winning_money   STRING     COMMENT '科研项目到款额(万元)',
                                        topic_num   STRING     COMMENT '课题总数',
                                        scientific_team_num   STRING     COMMENT '科研团队数量',
                                        monograph_num   STRING     COMMENT '专著数量',
                                        paper_num   STRING     COMMENT '论文数量',
                                        patent_num   STRING     COMMENT '专利数量',
                                        project_num   STRING     COMMENT '项目数量'
                                )COMMENT  '学院科研工作统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院科研工作统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
                select
                a.semester_year,
                if (b.prize_winning_num is null,0,b.prize_winning_num) as prize_winning_num,
                if (c.prize_winning_money is null,0,c.prize_winning_money) as prize_winning_money,
                if (d.topic_num is null,0,d.topic_num) as topic_num,
                if (e.scientific_team_num is null,0,e.scientific_team_num) as scientific_team_num,
                if (f.monograph_num is null,0,f.monograph_num) as monograph_num,
                if (g.paper_num is null,0,g.paper_num) as paper_num,
                if (h.patent_num is null,0,h.patent_num) as patent_num,
                if (i.project_num is null,0,i.project_num) as project_num
                from (
                    select distinct semester_year from model.basic_semester_info
                    ) a  left join  (
                        select count(code) as prize_winning_num, semester_year from model.scientific_award_result_info group by semester_year
                    ) b on a.semester_year=b.semester_year
                    left join(
                        select sum(arrival_account_money) as prize_winning_money, semester_year from model.scientific_project_funds_info group by semester_year
                    ) c on a.semester_year=c.semester_year
                    left join(
                        select count(main_subject) as topic_num,semester_year from model.scientific_project_basic_info where main_subject is not null and main_subject != '' group by semester_year
                    )d on a.semester_year=d.semester_year
                    left join(
                        select count(code) as scientific_team_num, semester_year from model.scientific_team_info group by semester_year,code
                    )e on a.semester_year=e.semester_year
                    left join(
                        select count(code) as monograph_num,semester_year from model.scientific_work_basic_info group by semester_year
                    )f on a.semester_year=f.semester_year
                    left join(
                        select count(code) as paper_num,semester_year from model.scientific_paper_basic_info group by semester_year
                    )g on a.semester_year=g.semester_year
                    left join(
                        select count(patent_code) as patent_num,semester_year from model.scientific_patent_achievements group by semester_year
                    )h on a.semester_year=h.semester_year
                    left join(
                        select count(code) as project_num,semester_year from model.scientific_project_basic_info group by semester_year
                    )i on a.semester_year=i.semester_year
                    order by a.semester_year desc

        "
        fn_log " 导入数据--学院科研工作统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "semester_year,prize_winning_num,prize_winning_money,topic_num,scientific_team_num,monograph_num,paper_num,patent_num,project_num"

    fn_log "导出数据--学院科研工作统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
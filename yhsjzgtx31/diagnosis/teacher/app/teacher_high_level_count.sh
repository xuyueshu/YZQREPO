#!/bin/sh
###################################################
###   基础表:      教师高层次人才统计表
###   维护人:      ZhangWeiCe
###   数据源:       model.basic_teacher_info,

###  导入方式:      全量导入
###  运行命令:      sh teacher_high_level_count.sh &
###  结果目标:      app.teacher_high_level_count
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir teacher_high_level_count

HIVE_DB=app
HIVE_TABLE=teacher_high_level_count
TARGET_TABLE=teacher_high_level_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        semester_year   STRING     COMMENT '学年',
                                        loss_num   STRING     COMMENT '高层次人才流失人数',
                                        introduce_num   STRING     COMMENT '高层次人才引入人数',
                                        all_num   STRING     COMMENT '当年高层次人才总人数'        )COMMENT  '教师高层次人才统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师高层次人才统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
#总人数，学年
       hive -e "
        create TABLE tmp.tmp_teacher_high_level_count AS

select count(1)  as num , semester_year from model.basic_teacher_info
GROUP BY semester_year
    ;"

#流失人数，学年
        hive -e "
        create TABLE tmp.tmp_teacher_high_level_out AS
        select
            case when nvl(b.num,0)- nvl(a.num,0)>0 then nvl(b.num,0)- nvl(a.num,0) else 0 end num,
            a.semester_year semester_year
        from
	        ( select count(distinct code) num ,semester_year from model.basic_teacher_info
	        group by semester_year) a

	        left join(
    	        select count(distinct code) num,semester_year from model.basic_teacher_info
    	        group by semester_year
	        ) b on a.semester_year=CONCAT(cast(substr(b.semester_year,1,4)+1 as int),'-',cast(substr(b.semester_year,6,4)+1 as int))

    ;"

#引进人数，学年

  hive -e "
        create TABLE tmp.tmp_teacher_high_level_in AS
            select
                case when nvl(a.num,0)- nvl(b.num,0)>0 then  nvl(a.num,0)- nvl(b.num,0) else 0 end num,a.semester_year semester_year
            from
                (select count(distinct code) num ,semester_year from model.basic_teacher_info
                group by semester_year
                ) a
                left join(
                    select count(distinct code) num,semester_year from model.basic_teacher_info
                    group by semester_year
                ) b on a.semester_year=CONCAT(cast(substr(b.semester_year,1,4)+1 as int),'-',cast(substr(b.semester_year,6,4)+1 as int))

    ;"
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
                            aa.semester_year as semester_year,
                            if(bb.num is null,0,bb.num) as loss_num,
                            if(cc.num is null,0,cc.num) as introduce_num,
                            aa.num as all_num
                from tmp.tmp_teacher_high_level_count aa
                left join tmp.tmp_teacher_high_level_out bb on aa.semester_year=bb.semester_year
                left join tmp.tmp_teacher_high_level_in cc on aa.semester_year=cc.semester_year
        "
        hive -e "
        drop TABLE tmp.tmp_teacher_high_level_count;
        drop TABLE tmp.tmp_teacher_high_level_out;
        drop TABLE tmp.tmp_teacher_high_level_in;
    ;"
        fn_log " 导入数据--教师高层次人才统计表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "semester_year,loss_num,introduce_num,all_num"

    fn_log "导出数据--教师高层次人才统计表: ${HIVE_DB}.${TARGET_TABLE}"

}


init_exit
create_table
import_table
export_table
finish
#!/bin/sh
###################################################
###   基础表:      学院党员人数信息表
###   维护人:      yangsh
###   数据源:      model.basic_semester_info,model.basic_teacher_info,app.basic_semester_student_info,model.basic_student_info
###                 model.party_activity_info,model.party_honor_info,model.party_fee_info

###  导入方式:      全量导入
###  运行命令:      sh college_party_info.sh &
###  结果目标:      app.college_party_info
###################################################

cd `dirname $0`
source ../../../config.sh
exec_dir college_party_info

HIVE_DB=app
HIVE_TABLE=college_party_info
TARGET_TABLE=college_party_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        teacher_party_count   STRING     COMMENT '教师党员人数',
                                        add_teacher_party_count   STRING     COMMENT '新增教师党员人数',
                                        teacher_party_rate   STRING     COMMENT '教师党员比率(存70.5,表示70.5%)',
                                        student_party_count   STRING     COMMENT '学生党员人数',
                                        add_student_party_count   STRING     COMMENT '新增学生党员人数',
                                        student_party_rate   STRING     COMMENT '学生党员比率(存20.5表示20.5%)',
                                        party_activity_count   STRING     COMMENT '党员活动次数',
                                        party_honor_count   STRING     COMMENT '党员荣誉次数',
                                        party_payed_count   STRING     COMMENT '已经缴费党员人数',
                                        party_unpayed_count   STRING     COMMENT '未缴费党员人数',
                                        semester_year   STRING     COMMENT '学年'
                                        )COMMENT  '学院党员人数信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院党员人数信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        SELECT
                            if (teacher_party_count is null,0,teacher_party_count) as teacher_party_count,
                            if (add_teacher_party_count is null,0,add_teacher_party_count) as add_teacher_party_count,
                            if (teacher_party_rate is null,0,teacher_party_rate) as teacher_party_rate,
                            if (student_party_count is null,0,student_party_count) as student_party_count,
                            if (add_student_party_count is null,0,add_student_party_count) as add_student_party_count,
                            if (student_party_rate is null,0,student_party_rate) as student_party_rate,
                            if (party_activity_count is null,0,party_activity_count) as party_activity_count,
                            if (party_honor_count is null,0,party_honor_count) as party_honor_count,
                            if (party_payed_count is null,0,party_payed_count) as party_payed_count,
                            if (party_unpayed_count is null,0,party_unpayed_count) as party_unpayed_count,
                            semester_year as semester_year
                from
                    (
		                select
								b.teacher_dy_num as teacher_party_count,
								b.teacher_dy_num-c.teacher_dy_num_qn as add_teacher_party_count,
								round(b.teacher_dy_num/d.teacher_num*100,2) as teacher_party_rate,
								e.stu_dy_num as student_party_count,
								e.stu_dy_num-f.stu_dy_num_qn as add_student_party_count,
								round(e.stu_dy_num/g.stu_num*100,2) as student_party_rate,
								h.party_activity_count,
								i.party_honor_count,
								j.yjf as party_payed_count,
								j.wjf as party_unpayed_count,
								a.semester_year
								from (select distinct semester_year from model.basic_semester_info) a
								left join(
									SELECT
									count(code) as teacher_dy_num,semester_year
									from
									model.basic_teacher_info
									where politics_status='01'
									group by semester_year
								) b on a.semester_year=b.semester_year
								left join(
									SELECT
									count(code) as teacher_dy_num_qn,semester_year
									from
									model.basic_teacher_info
									where politics_status='01'
									group by semester_year
								) c on SUBSTR(a.semester_year,1,4)=SUBSTR(c.semester_year,6,9)
								left join(
								SELECT
									count(code) as teacher_num,semester_year
									from
									model.basic_teacher_info
									group by semester_year
								) d on a.semester_year=d.semester_year
								left join (
									select count(b.code) as stu_dy_num,semester_year
									from
									app.basic_semester_student_info a
									left join (select code from model.basic_student_info where political_status='01')b on a.code=b.code
									group by semester_year
								) e on a.semester_year=e.semester_year
								left join (
									select count(b.code) as stu_dy_num_qn,semester_year
									from
									app.basic_semester_student_info a
									left join (select code from model.basic_student_info where political_status='01')b on a.code=b.code
									group by semester_year
								) f on SUBSTR(a.semester_year,1,4)=SUBSTR(f.semester_year,6,9)
								left join (
									select count(code) as stu_num,semester_year
									from
									app.basic_semester_student_info group by semester_year
								) g on a.semester_year=g.semester_year
								left join (
									select count(0) as party_activity_count,semester_year from model.party_activity_info group by semester_year
								) h on a.semester_year=h.semester_year
								left join (
									select count(0) as party_honor_count, semester_year from model.party_honor_info group by semester_year
								) i on a.semester_year=i.semester_year
								left join (
								select sum(wjf) as wjf,sum(yjf) as yjf,semester_year from (
									select
									case when status=0 then 1 else 0 end wjf,
									case when status=1 then 1 else 0 end yjf,
									semester_year
									from model.party_fee_info
									) aa group by semester_year
								) j on a.semester_year=j.semester_year
        ) A
        "
        fn_log " 导入数据--学院党员人数信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "teacher_party_count,add_teacher_party_count,teacher_party_rate,student_party_count,add_student_party_count,student_party_rate,party_activity_count,party_honor_count,party_payed_count,party_unpayed_count,semester_year"

    fn_log "导出数据--学院党员人数信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
#!/bin/sh
###################################################
###   基础表:      专业招生人数
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_enroll_student.sh &
###  结果目标:      model.major_enroll_student
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_enroll_student

HIVE_DB=model
HIVE_TABLE=major_enroll_student
TARGET_TABLE=major_enroll_student

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        academy_code   STRING     COMMENT '学院编号',
                                        academy_name   STRING     COMMENT '学院名称',
                                        actual_enroll_student_count   STRING     COMMENT '实际报道人数',
                                        actual_admission_count   STRING     COMMENT '实际录取人数',
                                        plan_enroll_student_count   STRING     COMMENT '计划招生人数',
                                        overseas_student_count   STRING     COMMENT '留学生人数',
                                        report_rate   STRING     COMMENT '报到率',
                                        first_volunteer_rate   STRING     COMMENT '第一志愿报考率',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '专业招生人数'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业招生人数: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
                      select  a.major_code major_code,
                              a.major_name major_name,
                              a.department_code department_code,
                              a.department_name department_name,
                              cast(nvl(b.actual_enroll_student_count,0) as int) actual_enroll_student_count,
                              cast(nvl(c.actual_admission_count,0) as int) actual_admission_count,
                              cast(nvl(a.plan_enroll_student_count,0) as int) plan_enroll_student_count,
                              0 overseas_student_count,
                              case when (a.plan_enroll_student_count is null or plan_enroll_student_count=0)
                              then 0 else round(nvl(b.actual_enroll_student_count,0)/a.plan_enroll_student_count*100,2) end report_rate,
                              case when (a.plan_enroll_student_count is null or plan_enroll_student_count=0)
                              then 0 else round(nvl(d.first_volunteer,0)/a.plan_enroll_student_count*100,2) end first_volunteer_rate,
                              a.semester_year semester_year
                        from (

                            select zsjh.xn as 	semester_year,
                                              zsjh.ybmc department_name,
                                              zsjh.ybbh department_code,
                                              zsjh.zymc major_name,
                                              zsjh.zybh major_code,
                                              sum(zsjh.zyjh) plan_enroll_student_count
                            from raw.rs_T_ZG_ZSJHB  zsjh group by zsjh.xn,zsjh.ybmc,zsjh.ybbh,zsjh.zymc,zsjh.zybh) a
                            left join

                            (SELECT count(1) actual_enroll_student_count,concat(ksxx.xn,'-',cast(ksxx.xn as int)+1) as semester_year,
                                        ksxx.lqzydm as major_code
                                       from raw.rs_t_zg_ksxx  ksxx
                             where ksxx.sfbd='是'
                            group by ksxx.lqzydm,concat(ksxx.xn,'-',cast(ksxx.xn as int)+1)) b on a.major_code=b.major_code and a.semester_year=b.semester_year

                            left join(
                              SELECT count(1) actual_admission_count,concat(ksxx.xn,'-',cast(ksxx.xn as int)+1) as semester_year,
                                          ksxx.lqzydm as major_code
                                         from raw.rs_t_zg_ksxx  ksxx
                              group by ksxx.lqzydm,concat(ksxx.xn,'-',cast(ksxx.xn as int)+1)) c on a.major_code=c.major_code and a.semester_year=c.semester_year
                            left join(
                              SELECT count(1) first_volunteer,concat(ksxx.xn,'-',cast(ksxx.xn as int)+1) as semester_year,
                                          ksxx.lqzydm as major_code
                                         from raw.rs_t_zg_ksxx  ksxx
                               where ksxx.sfdyzylq='是'
                              group by ksxx.lqzydm,concat(ksxx.xn,'-',cast(ksxx.xn as int)+1)) d on a.major_code=d.major_code and a.semester_year=d.semester_year

        "
        fn_log " 导入数据--专业招生人数: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "major_code,major_name,academy_code,academy_name,actual_enroll_student_count,actual_admission_count,plan_enroll_student_count,overseas_student_count,report_rate,first_volunteer_rate,semester_year"

    fn_log "导出数据--专业招生人数: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
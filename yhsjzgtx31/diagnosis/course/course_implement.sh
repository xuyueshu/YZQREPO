#!/bin/sh
###################################################
###   基础表:      课程教学实施表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh course_implement.sh &
###  结果目标:      model.course_implement
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir course_implement

HIVE_DB=model
HIVE_TABLE=course_implement
TARGET_TABLE=course_implement

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        course_code   STRING     COMMENT '课程代码',
                                        teacher_code   STRING     COMMENT '授课教师代码',
                                        teacher_name   STRING     COMMENT '授课教师姓名',
                                        homework_num   STRING     COMMENT '次数',
                                        test_num   STRING     COMMENT '随堂测试次数',
                                        online_answer_num   STRING     COMMENT '线上答疑次数',
                                        online_discuss_num   STRING     COMMENT '小组讨论次数',
                                        academy_code   STRING     COMMENT '学院编号',
                                        academy_name   STRING     COMMENT '学院名称',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        category   STRING     COMMENT '课程类别:0理论,1实践,2理论加实践,99其他',
                                        work_correction_rate   STRING     COMMENT '作业批改率',
                                        sign_rate   STRING     COMMENT '学生签到率',
                                        questions_rate   STRING     COMMENT '学生提问率',
                                        forum_posting_rate   STRING     COMMENT '论坛发帖率'        )COMMENT  '课程教学实施表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--课程教学实施表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
        distinct
        nvl(substr(a.XKKH,2,9),'') as semester_year,
        nvl(substr(a.XKKH,12,1),'') as semester,
        nvl(a.KCBH,'') as course_code,
        nvl(a.RKJSBH,'') as teacher_code,
        a.RKJSXM as teacher_name,
        nvl(h.homework_num,0) homework_num,
        nvl(t.tests_num,0) test_num,
        nvl(an.answer_num,0) online_answer_num,
        nvl(dis.dis_num,0) online_discuss_num,
        nvl(a.KKYBBH,'') as academy_code,
        nvl(a.KKYBMC,'') as academy_name,
        nvl(a.SYZYDM,'')as major_code,
        nvl(a.SYZY,'') as major_name,
        case
            when a.KCLX='理论课' then 0
            when a.KCLX='实践课' then 1
            when a.KCLX='理论+实践课' then 2
            else 99 end as category,
        0 work_correction_rate,
        0 sign_rate,
        nvl(qu.question_rate,0) questions_rate,
        nvl(qu.send_rate,0) forum_posting_rate

        from raw.sw_T_ZG_KCXXB a

        left join (
            select  count(1) homework_num,aa.semester_year,aa.semester,course.scourseNO scourseNO
            from
                (select  b.*,a.semester_year,a.semester from model.basic_semester_info a, raw.te_achievement_test b
                where a.begin_time<=b.start_time and a.end_time>=b.start_time) aa
            left join raw.te_oc oc on aa.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            where (aa.test_type=1 or aa.test_type=2)
            group by aa.semester_year,aa.semester,course.scourseNO
        ) h on substr(a.XKKH,2,9)=h.semester_year and substr(a.XKKH,12,1)=h.semester and a.KCBH=h.scourseNO

         left join (
            select  count(1) tests_num,aa.semester_year,aa.semester,course.scourseNO scourseNO
            from
                (select  b.*,a.semester_year,a.semester from model.basic_semester_info a, raw.te_achievement_test b
                where a.begin_time<=b.start_time and a.end_time>=b.start_time) aa
            left join raw.te_oc oc on aa.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            where aa.test_type=3
            group by aa.semester_year,aa.semester,course.scourseNO
        ) t on substr(a.XKKH,2,9)=t.semester_year and substr(a.XKKH,12,1)=t.semester and a.KCBH=t.scourseNO

        left join (
            select  sum(reply_count) answer_num,aa.semester_year,aa.semester,course.scourseNO scourseNO
            from
                (select  b.*,a.semester_year,a.semester from model.basic_semester_info a, raw.te_achievement_online_forum_qa b
                where a.begin_time<=b.create_time and a.end_time>=b.create_time) aa
            left join raw.te_oc oc on aa.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            group by aa.semester_year,aa.semester,course.scourseNO
        ) an on substr(a.XKKH,2,9)=an.semester_year and substr(a.XKKH,12,1)=an.semester and a.KCBH=an.scourseNO

        left join(
            select round(sum(question_count/stu_num),2) question_rate, round(sum(send_count/stu_num),2) send_rate,aa.semester_year,aa.semester,course.scourseNO scourseNO
            from
                (select  b.*,a.semester_year,a.semester from model.basic_semester_info a, raw.te_achievement_online_forum_qa b
                where a.begin_time<=b.create_time and a.end_time>=b.create_time) aa

            left join raw.te_oc oc on aa.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            left join (select count(distinct iuser_id) stu_num,iclass_id from raw.te_class_student
                        group by iclass_id) class on aa.iclass_id=class.iclass_id
            group by aa.semester_year,aa.semester,course.scourseNO
        )qu on substr(a.XKKH,2,9)=qu.semester_year and substr(a.XKKH,12,1)=qu.semester and a.KCBH=qu.scourseNO

        left join(
             select  count(1) dis_num,aa.semester_year,aa.semester,course.scourseNO scourseNO
            from
                (select  b.*,a.semester_year,a.semester from model.basic_semester_info a, raw.te_oc_forum b
                where a.begin_time<=b.create_time and a.end_time>=b.create_time) aa
            left join raw.te_oc oc on aa.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            where aa.itype=3
            group by aa.semester_year,aa.semester,course.scourseNO
        )dis on substr(a.XKKH,2,9)=dis.semester_year and substr(a.XKKH,12,1)=dis.semester and a.KCBH=dis.scourseNO
        "
        fn_log " 导入数据--课程教学实施表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "semester_year,semester,course_code,teacher_code,teacher_name,homework_num,test_num,online_answer_num,online_discuss_num,academy_code,academy_name,major_code,major_name,category,work_correction_rate,sign_rate,questions_rate,forum_posting_rate"

    fn_log "导出数据--课程教学实施表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
#!/bin/sh
###################################################
###   基础表:      教师课表数据表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_course_info.sh &
###  结果目标:      app.teacher_course_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_course_info

HIVE_DB=model
HIVE_TABLE=teacher_course_info
TARGET_TABLE=teacher_course_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        course_code   STRING     COMMENT '课程号',
                                        course_name   STRING     COMMENT '课程名',
                                        class_number   STRING     COMMENT '上课班级号(课序号)',
                                        code   STRING     COMMENT '任课教师工号',
                                        name   STRING     COMMENT '任课教师姓名',
                                        weekly_times   STRING     COMMENT '周次',
                                        week_day   STRING     COMMENT '星期几',
                                        single_double_week   STRING     COMMENT '单双周',
                                        festivals   STRING     COMMENT '节次',
                                        room   STRING     COMMENT '上课地点',
                                        student_number   STRING     COMMENT '上课班级人数',
                                        examination_method   STRING     COMMENT '考试方式',
                                        credit   STRING     COMMENT '学分',
                                        teaching_hours   STRING     COMMENT '讲授学时',
                                        experiment_hours   STRING     COMMENT '实验学时',
                                        computer_hours   STRING     COMMENT '上机学时',
                                        other_hours   STRING     COMMENT '其他学时',
                                        commencement_instruction   STRING     COMMENT '开课说明'        )COMMENT  '教师课表数据表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师课表数据表: ${HIVE_DB}.${HIVE_TABLE}"
}


function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select distinct
            a.KBXN semester_year,
            a.KBXQ semester,
            a.KBKCDM course_code,
            a.KBKCMC course_name,
            a.BJDM class_number,
            a.JSZGH code,
            a.JKJS name,
            SKZC weekly_times,
            XQJ  week_day,
            1 single_double_week,
            a.KBZXS festivals,
            JSBH room,
            a.XSRS student_number,
            KHFS examination_method,
            c.xf credit,
            round(b.LLXS/nvl(cast(split(skzc, '-')[1] as int)-cast(split(skzc, '-')[0] as int)+1,1),2) teaching_hours,
            round(b.SJXS/nvl(cast(split(skzc, '-')[1] as int)-cast(split(skzc, '-')[0] as int)+1,1),2) experiment_hours,
            0 computer_hours,
            round((c.ZTXS-c.LLXS-c.SJXS),2) other_hours,
            '' commencement_instruction
        from raw.zgy_t_zg_jskb a
        left join raw.zgy_t_zg_jskbxx b on a.KBKCDM=b.KCDM and substr(a.xkkh,23,10)=b.LSBH and a.kbxn=b.xn and a.kbxq=b.xq
        left join (select * from
                        (select row_number() over(partition by  KCBH,SKFS,KHFS,ZTXS,LLXS,SJXS,RKJSBH order by XF  desc) as rownum, KCBH,SKFS,KHFS,XF,ZTXS,LLXS,SJXS,RKJSBH
                    from raw.sw_t_zg_kcxxb) a where rownum=1  ) c on a.KBKCDM=c.KCBH and a.JSZGH=c.RKJSBH

        "
        fn_log " 导入数据--教师课表数据表: ${HIVE_DB}.${HIVE_TABLE}"
}




init_exit
create_table
import_table
finish
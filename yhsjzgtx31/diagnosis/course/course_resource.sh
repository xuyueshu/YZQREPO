#!/bin/sh
###################################################
###   基础表:      课程资源表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh course_resource.sh &
###  结果目标:      model.course_resource
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir course_resource

HIVE_DB=model
HIVE_TABLE=course_resource
TARGET_TABLE=course_resource

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        course_code   STRING     COMMENT '课程代码',
                                        course_name   STRING     COMMENT '课程名称',
                                        online_num   STRING     COMMENT '是否在线课程(1是 2否)',
                                        online_exercises_num   STRING     COMMENT '在线课程练习题数量',
                                        academy_code   STRING     COMMENT '学院编号',
                                        academy_name   STRING     COMMENT '学院名称',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        teacher_code   STRING     COMMENT '教师编号',
                                        teacher_name   STRING     COMMENT '教师名称',
                                        category   STRING     COMMENT '课程类型:课程类别:0理论,1实践,2理论加实践,99其他',
                                        picture_num   STRING     COMMENT '图片数量',
                                        text_num   STRING     COMMENT '文本数量',
                                        video_num   STRING     COMMENT '视频数量',
                                        audio_num   STRING     COMMENT '音频数量',
                                        knowledge_points_num   STRING     COMMENT '知识点数量',
                                        online_examination_paper_num   STRING     COMMENT '在线试卷试卷',
                                        resources_material   STRING     COMMENT '教学资料数量=图片+文本+视频+音频数量的总和',
                                        level   STRING     COMMENT '课程级别(1国家级 2省级 3院级)'        )COMMENT  '课程资源表'
                                        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--课程资源表: ${HIVE_DB}.${HIVE_TABLE}"
}

#是否在线课程 / 在线课程练习题数量 /图片数量 /文本数量/视频数量/音频数量/知识点数量
#在线试卷试卷 /教学资料数量/课程级别
function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
        distinct
        nvl(substr(a.XKKH,2,9),'') as semester_year,
        nvl( substr(a.XKKH,12,1),'') as semester,
        nvl(a.KCBH,'') as course_code,
        a.KCMC as course_name,
        case when oc.id is not null then 2 else 1 end as online_num,
        nvl(ex.ex_num,0) as online_exercises_num,
        nvl(a.KKYBBH,'') as academy_code,
        nvl(a.KKYBMC,'') as academy_name,
        nvl(a.SYZYDM,'')as major_code,
        nvl(a.SYZY,'') as major_name,
        nvl(a.RKJSBH,'') as teacher_code,
        a.RKJSXM as teacher_name,
        case
            when a.KCLX='理论课' then 0
            when a.KCLX='实践课' then 1
            when a.KCLX='理论+实践课' then 2
            else 99 end as category,
         nvl(b.pic_num,0) as picture_num,
         nvl(b.doc_num,0) as text_num,
         nvl(b.vio_num,0) as video_num,
         nvl(b.audio_num,0) as audio_num,
         nvl(ken.ken_num,0) as knowledge_points_num,
         nvl(paper.paper_num,0) as  online_examination_paper_num,
         nvl(nvl(b.pic_num,0)+nvl(b.doc_num,0)+nvl(b.vio_num,0)+nvl(b.audio_num,0),0) as resources_material,
         3 as  level
        from raw.sw_T_ZG_KCXXB a
        left join (
             SELECT
                sum(case when ifile_type=6 then 1 else 0 end)  pic_num,
                sum(case when (ifile_type=2 or ifile_type=3 or ifile_type=4 or ifile_type=5 or ifile_type=7 or ifile_type=8) then 1 else 0 end) doc_num,
                sum(case when ifile_type=1 then 1 else 0 end) vio_num,
                sum(case when ifile_type=9 then 1 else 0 end) audio_num,
                course.scourseNO scourseNO
            FROM raw.te_resources re
            left join raw.te_oc oc on re.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            GROUP BY course.scourseNO
        ) b on a.KCBH=b.scourseNO
        left join (
             select oc.*,te.steacherNO,course.scourseNO scourseNO
             from raw.te_oc oc
             left join raw.te_teacher te on oc.iteacher_id=te.id
             left join raw.te_course course on oc.icourse_id=course.id
        ) oc on a.KCBH=oc.scourseNO and a.RKJSBH=oc.steacherNO
        left join (
            select count(1) paper_num,course.scourseNO scourseNO
            from raw.te_paper p
            left join raw.te_oc oc on p.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            where p.is_deleted=0
            group by course.scourseNO
        ) paper on a.kcbh=paper.scourseNO
        left join (
            select count(1) ken_num,course.scourseNO scourseNO
            from raw.te_ken ken
            left join raw.te_oc oc on ken.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            group by course.scourseNO
        ) ken on a.kcbh=ken.scourseNO

        left join (
            select count(1) ex_num,course.scourseNO scourseNO from raw.te_exercise exer
            left join raw.te_oc oc on exer.ioc_id=oc.id
            left join raw.te_course course on oc.icourse_id=course.id
            where exer.is_deleted=0
            group by course.scourseNO
        ) ex on a.kcbh=ex.scourseNO
        "
        fn_log " 导入数据--课程资源表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "semester_year,semester,course_code,course_name,online_num,online_exercises_num,academy_code,academy_name,major_code,major_name,teacher_code,teacher_name,category,picture_num,text_num,video_num,audio_num,knowledge_points_num,online_examination_paper_num,resources_material,level"

    fn_log "导出数据--课程资源表: ${HIVE_DB}.${TARGET_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    let vDate+=1;
    years=3
    for((i=1;i<=3;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
      export_table
    done
}
#第一次执行create_table--getYearData  循环近3年的
#第二次执行import_table where后的变量改成 '${SEMESTER_YEARS}'
init_exit
create_table
import_table
export_table
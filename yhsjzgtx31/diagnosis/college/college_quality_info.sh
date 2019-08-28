#!/bin/sh
###################################################
###   基础表:      学院教学质量信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_quality_info.sh &
###  结果目标:      model.college_quality_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_quality_info

HIVE_DB=model
HIVE_TABLE=college_quality_info
TARGET_TABLE=college_quality_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        supervisor_attendance_time   STRING     COMMENT '督导听课数量',
                                        teaching_inspections_count   STRING     COMMENT '教学检查数量',
                                        first_class_professional   STRING     COMMENT '一流专业数',
                                        backbone_professional   STRING     COMMENT '骨干专业',
                                        major_teach_resource   STRING     COMMENT '专业教学资源库',
                                        online_course_count   STRING     COMMENT '精品在线开放课程数',
                                        innovation_department   STRING     COMMENT '创新创业试点系',
                                        teach_awrad   STRING     COMMENT '教学成果奖数量',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '学院教学质量信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院教学质量信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select
                0 supervisor_attendance_time,
                0 teaching_inspections_count,
                a.zysl first_class_professional,
                b.zysl backbone_professional,
                d.zyzyksl major_teach_resource,
                c.jpkcsl online_course_count,
                0 innovation_department,
                0 teach_awrad,
                a.semester_year semester_year
            from(
            select  '${semester}'semester_year , count(zydm) zysl
            FROM raw.zgy_t_zg_zyxx
            where trim(JSJC)='省级重点专业'
            and cast(substr(zyszsj,1,4) as int)<='${NOW_YEAR}') a

            left join

            (select  '${semester}'semester_year , count(zydm) zysl
            FROM raw.zgy_t_zg_zyxx
            where trim(JSJC)='骨干专业'
            and cast(substr(zyszsj,1,4) as int)<='${NOW_YEAR}') b on a.semester_year=b.semester_year

            left join

            (select  '${semester}'semester_year , count(icourse_id) jpkcsl
            FROM raw.te_oc
            where is_portal_course in(1,3)
            and cast(substr(create_time,1,4) as int)<='${NOW_YEAR}') c on a.semester_year=c.semester_year

            left join

             (select  XN semester_year , count(1) zyzyksl
            FROM raw.te_t_zg_zyjxzyk
            where XN='${semester}' group by xn) d on a.semester_year=d.semester_year


        "
        fn_log " 导入数据--学院教学质量信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year = '${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "supervisor_attendance_time,teaching_inspections_count,first_class_professional,backbone_professional,major_teach_resource,online_course_count,innovation_department,teach_awrad,semester_year"

    fn_log "导出数据--学院教学质量信息表: ${HIVE_DB}.${TARGET_TABLE}"

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
#import_table
#export_table
finish
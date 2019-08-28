#!/bin/sh
###################################################
###   基础表:      专业学期课程表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_course_record.sh &
###  结果目标:      model.major_course_record
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_course_record

HIVE_DB=model
HIVE_TABLE=major_course_record
TARGET_TABLE=major_course_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '学院编号',
                                        academy_name   STRING     COMMENT '学院名称',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        course_code   STRING     COMMENT '课程代码',
                                        course_name   STRING     COMMENT '课程名称',
                                        course_attr   STRING     COMMENT '课程属性,参见emnu_info中COURSEATTR类型的枚举，保存对应code',
                                        course_type   STRING     COMMENT '课程性质,参见emnu_info中COURSETYPE类型的枚举，保存对应code',
                                        total_hour   STRING     COMMENT '总学时',
                                        theory_hour   STRING     COMMENT '理论学时',
                                        practice_hour   STRING     COMMENT '实践学时',
                                        category   STRING     COMMENT '课程类别:0理论,1实践,2理论加实践,99其他',
                                        developmentType   STRING     COMMENT '发展类课程:参见枚举emnu_info FZKC 创新创业类：CXCY',
                                        is_core_course   STRING     COMMENT '是否核心课程:0否 1是',
                                        is_corporate_development   STRING     COMMENT '是否是校企合作开发课程:0否 1是',
                                        credit   STRING     COMMENT '学分',
                                        semester_year   STRING     COMMENT '学年',
                                        semester   STRING     COMMENT '学期',
                                        is_open   STRING     COMMENT '是否开课，1为开课，空或0为未开课',
                                        good_course   STRING     COMMENT '精品课程:国家级，省部级，地市级，院校级',
                                        sum_class_hour   STRING     COMMENT '总课时'        )COMMENT  '专业学期课程表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业学期课程表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select distinct
                KKYBBH academy_code,
                KKYBMC academy_name,
                SYZYDM major_code,
                SYZY major_name,
                a.KCBH course_code,
                a.KCMC course_name,
                case when KCSX like '%专业%' then 'ZYLLK' when KCSX like '%公共%' then 'GGJCK' else 'ZYSJK' end course_attr,
                case when KCXZ like '%必修%' then 'BX' when KCXZ like '%选修%' then 'RX' end course_type,
                ZTXS total_hour,
                LLXS theory_hour,
                SJXS practice_hour,
                case when KCLX ='理论课' then '0' when KCLX ='实践课' then '1' when KCLX ='理论+实践课' then '2' else '99' end category,
                'QT' developmentType,
                case when SFZYHXK='是' then '1' else '0' end is_core_course,
                case when b.kcbh is not null then '1' else '0' end is_corporate_development,
                XF credit,
                substr(XKKH,2,9) semester_year,
                substr(XKKH,12,1) semester,
                1 is_open,
                '' good_course,
                0 sum_class_hour
            FROM raw.sw_t_zg_kcxxb a
            left join raw.ec_T_ZG_XQHZKFKCXX b on a.KCBH=b.KCBH

        "
        fn_log " 导入数据--专业学期课程表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,academy_name,major_code,major_name,course_code,course_name,course_attr,course_type,total_hour,theory_hour,practice_hour,category,developmentType,is_core_course,is_corporate_development,credit,semester_year,semester,is_open,good_course,sum_class_hour"

    fn_log "导出数据--专业学期课程表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
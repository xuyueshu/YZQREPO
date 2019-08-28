#!/bin/sh
cd `dirname $0`
source ././../config.sh
exec_dir base_major_info

HIVE_DB=assurance
HIVE_TABLE=base_student_info
TARGET_TABLE=base_student_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                student_no String COMMENT '学生编号',
                student_name String COMMENT '学生姓名',
                identification_card String COMMENT '学生身份证号',
                email String COMMENT '学生电子邮件',
                phone String COMMENT '学生手机号码',
                wechat_number String COMMENT '学生微信号',
                educational_system String COMMENT '学制  3  三年制  5 五年制',
                grade String COMMENT '年级  格式：yyyy  入学年份',
                department_no String COMMENT '学生所属的系编号',
                department_name String COMMENT '学生所属的系名称',
                major_no String COMMENT '学生所属的专业编号',
                major_name String COMMENT '学生所属的专业名称',
                class_no String COMMENT '学生所属的班级编号',
                class_name String COMMENT '学生所属的班级名称',
                is_school String COMMENT '是否在校',
                create_time String COMMENT '创建时间'
    ) COMMENT '学生基本信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——学生基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
            select
              distinct a.code as student_no,
              a.name as student_name,
              a.identity_card as identification_card,
              a.email as email,
              a.phone as phone,
              null as wechat_number,
              a.educational_system as educational_system,
              substr(a.enrolment_date,1,4) as grade,
              a.academy_code as department_no,
              a.academy_name as department_name,
              a.major_code as major_no,
              a.major_name as major_name,
              a.class_code as class_no,
              a.class_name as class_name,
              case when a.in_school = '0' then 'NO' else 'YES' end as is_school,
              FROM_UNIXTIME(
                UNIX_TIMESTAMP()
              ) AS create_time
            from
              model.basic_student_info a
    "
    fn_log "导入数据 —— 学生基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'student_no,student_name,identification_card,email,phone,wechat_number,educational_system,grade,department_no,department_name,major_no,major_name,class_no,class_name,is_school,create_time'

    fn_log "导出数据--学生基本信息表:${HIVE_DB}.${TARGET_TABLE}"
}

#create_table
#import_table
export_table
finish

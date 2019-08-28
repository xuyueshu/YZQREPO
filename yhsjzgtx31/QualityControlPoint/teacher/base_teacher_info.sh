#!/bin/sh
cd `dirname $0`
source ././../config.sh
exec_dir base_teacher_info

HIVE_DB=assurance
HIVE_TABLE=base_teacher_info
TARGET_TABLE=base_teacher_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                teacher_no  String comment '教职工编号',
                teacher_name String comment '教职工姓名',
                department_no  String comment ' 归属部门编号',
                department_name String comment '部门名称',
                job_title String comment '职称  ZG 正高、FG 副高、ZJ 中级、CJ 初级 QT 其它',
                education String comment '学历  YJS 研究生（博士研究生、硕士研究生）、BK 本科生、DZ 大专、ZZ 中专、GZ 高中 QT 其它',
                degree String comment '学位 BS 博士、SX 硕士、XS 学士 QT 其它',
                is_duty String comment '是否在职 YES 是 NO 否',
                create_time String COMMENT '创建时间 格式：YYYY-MM-DD HH:mm:ss'
    ) COMMENT '教职工基本信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——教职工基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
                SELECT
                  c.teacher_no,
                  c.teacher_name,
                  c.department_no,
                  c.department_name,
                  case when c.job_title = '正高' then 'ZG'
                  when c.job_title = '副高' then 'FG'
                  when c.job_title = '中级' then 'ZJ'
                  when c.job_title = '初级' then 'CJ'
                  else 'QT' end as job_title,
                  case when c.education like '%研究生%' then 'YJS'
                  when c.education = '大学' then 'BK'
                  when c.education = '大专' then 'DZ'
                  when c.education = '中专' then 'ZZ'
                  when c.education = '高中' then 'GZ'
                  else 'QT' end as education,
                  case when c.degree = '博士' then 'BS'
                  when c.degree = '硕士' then 'SX'
                  when c.degree = '学士' then 'XS'
                  else 'QT' end as degree,
                  c.is_duty as duty,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                FROM
                  (
                    SELECT
                      row_number() OVER(
                        PARTITION BY b.teacher_no
                        ORDER BY
                          substr(b.semester_year, 1, 4) DESC
                      ) as num,
                      b.teacher_no,
                      b.teacher_name,
                      b.department_no,
                      b.department_name,
                      b.job_title,
                      b.education,
                      b.degree,
                      b.is_duty
                    FROM
                      (
                        select
                          distinct a.semester_year,
                          a.code as teacher_no,
                          a.name as teacher_name,
                          a.second_dept_code as department_no,
                          a.second_dept_name as department_name,
                          a.professional_title_level as job_title,
                          a.education as education,
                          a.degree as degree,
                          case when a.is_quit = '1' then 'NO' else 'YES' end as is_duty
                        from
                          model.basic_teacher_info a
                        where
                          a.second_dept_code is not null
                      ) b
                  ) c
                where
                  c.num = 1
    "
    fn_log "导入数据 —— 教职工基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'teacher_no,teacher_name,department_no,department_name,job_title,education,degree,is_duty,create_time'

    fn_log "导出数据--教职工基本信息表:${HIVE_DB}.${TARGET_TABLE}"
}

#create_table
#import_table
export_table
finish

#!/bin/sh
cd `dirname $0`
source ././../config.sh
exec_dir base_course_info

HIVE_DB=assurance
HIVE_TABLE=base_course_info
TARGET_TABLE=base_course_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                course_code String comment '课程代码',
                course_name String comment '课程名称',
                course_type String comment '课程类型 A 理论课  B 理论课+实践课  C 实践课',
                course_nature String comment '课程性质  BX 必修课  XX 选修课',
                is_new String comment '是否最新',
                create_time String comment '创建时间 格式：YYYY-MM-DD HH:mm:ss'
    ) COMMENT '课程基本信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表——课程基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

#课程编号有这样的：
#select * from base_course_info where course_code = 'SX07061402'
#
#895	SX07061402	顶岗实习	C	BXK	2019-03-06 13:43:51
#
#select * from base_course_info where course_code = 'sx07061402'
#
#1897	sx07061402	顶岗实习	C	BXK	2019-03-06 13:43:51
#
#第一位和第二位的字母大小写不同，其他的均相同

function import_table() {
    hive -e "
         INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
               SELECT
                  distinct c.course_code,
                  c.course_name,
                  c.course_type,
                  substr(c.course_nature, 1, 2),
                  'YES' as is_new,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                FROM
                  (
                    SELECT
                      row_number() OVER(
                        PARTITION BY b.course_code
                        ORDER BY
                          substr(b.semester_year, 1, 4) DESC
                      ) as num,
                      b.semester_year,
                      b.course_code,
                      b.course_name,
                      b.course_type,
                      b.course_nature
                    FROM
                      (
                        select
                          distinct a.semester_year,
                          a.course_code,
                          a.course_name,
                          case when a.category = 0 then 'A' when a.category = 2 then 'B' when a.category = 1 then 'C' end as course_type,
                          case when a.course_type='BX' then 'BX'
                               when a.course_type='XW' then 'BX'
                               when a.course_type='RX' then 'XX'
                               when a.course_type='XX' then 'XX' end as course_nature
                        from
                          model.major_course_record a
                      ) b
                  ) c
                WHERE
                  c.num = 1
                  and c.semester_year in (
                    SELECT
                      max(a.semester_year) as semester_year
                    FROM
                      model.major_course_record a
                  )
                UNION ALL
                SELECT
                  distinct c.course_code,
                  c.course_name,
                  c.course_type,
                  substr(c.course_nature, 1, 2),
                  'NO' as is_new,
                  FROM_UNIXTIME(
                    UNIX_TIMESTAMP()
                  ) AS create_time
                FROM
                  (
                    SELECT
                      row_number() OVER(
                        PARTITION BY b.course_code
                        ORDER BY
                          substr(b.semester_year, 1, 4) DESC
                      ) as num,
                      b.semester_year,
                      b.course_code,
                      b.course_name,
                      b.course_type,
                      b.course_nature
                    FROM
                      (
                        select
                          distinct a.semester_year,
                          a.course_code,
                          a.course_name,
                          case when a.category = 0 then 'A' when a.category = 2 then 'B' when a.category = 1 then 'C' end as course_type,
                          case when a.course_type='BX' then 'BX'
                               when a.course_type='XW' then 'BX'
                               when a.course_type='RX' then 'XX'
                               when a.course_type='XX' then 'XX' end as course_nature
                        from
                          model.major_course_record a
                      ) b
                  ) c
                WHERE
                  c.num = 1
                  and c.semester_year NOT IN (
                    SELECT
                      max(a.semester_year) as semester_year
                    FROM
                      model.major_course_record a
                  )
    "
    fn_log "导入数据 —— 课程基本信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_table() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'course_code,course_name,course_type,course_nature,is_new,create_time'

    fn_log "导出数据--课程基本信息表:${HIVE_DB}.${TARGET_TABLE}"
}

create_table
import_table
export_table
finish

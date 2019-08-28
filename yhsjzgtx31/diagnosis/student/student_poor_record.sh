#!/bin/sh
###################################################
###   基础表:      学生贫困生明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_poor_record

HIVE_DB=model
HIVE_TABLE=student_poor_record
TARGET_TABLE=student_poor_record

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              code      STRING    COMMENT '学生编号',
              semester_year      STRING    COMMENT '学年',
              economic_difficulties_survey      STRING    COMMENT '经济困难概况',
              is_economic_difficulties      STRING    COMMENT '是否经济困难',
              support_type      STRING    COMMENT '资助类型',
              support_amount      STRING    COMMENT '今年资助金额',
              support_time      STRING    COMMENT '上次资助时间',
              poor_type      STRING    COMMENT '贫困类型：参见enum_info中PKDJ类型的枚举，保存对应code',
              semester      STRING    COMMENT '学期'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生贫困生明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}

function import_table(){

        hive -e "
             INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                a.student_code as student_no,
                a.academic_year_name as semester_year,
                ' ' as economic_difficulties_survey,
                ' ' as is_economic_difficulties,
                '助学金' as support_type,
                a.amount as support_amount,
                case when c.PDXN is null then a.PDXN else c.PDXN end  as support_time,
                case when a.grant_type like '%一般贫困%' then 1
                    when a.grant_type like '%特困%' then 2
                    when a.grant_type like '%建档立卡%' then 3
                    end as poor_type,
                a.semester_name as semester
            from
            (
             SELECT
	           zzxx.xh as student_code,
	           zzxx.xm as student_name,
	           case when zzxx.xq='01' then 1
                when zzxx.xq='02' then 2
                 end
	            as semester_name,
	           zzxx.xn as academic_year_name,
	           zzxx.xmmc as grant_type,
	           zzxx.je as amount,
	           zzxx.PDXN
	           from raw.sw_t_zg_xg_zzxx zzxx
	           where zzxx.lbmc='助学金'
	           and zzxx.SFYBY='否'
            ) a
            left join
            (
                select
                student_code,
                PDXN
                from
                ( select
                  row_number() OVER(
                            PARTITION BY xh,PDXN
                          ) as num,
                  xh as student_code,
                  PDXN as PDXN
                  from
                  raw.sw_t_zg_xg_zzxx zzxx
                ) b
                where b.num=2
             ) c
            on a.student_code=c.student_code



        "
        fn_log " 导入数据--学生贫困生明细表:${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
--table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
--input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
--null-string '\\N' --null-non-string '\\N'  \
--columns "code,semester_year,economic_difficulties_survey,is_economic_difficulties,support_type,support_amount,support_time,poor_type,semester"

fn_log "导出数据--学生贫困生明细表:${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
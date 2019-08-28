#!/bin/sh
###################################################
###   基础表:      学生成绩明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_score_record

HIVE_DB=model
HIVE_TABLE=student_score_record
TARGET_TABLE=student_score_record

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              code      STRING    COMMENT '学生编号',
              semester_year      STRING    COMMENT '学年',
              semester      STRING    COMMENT '学期',
              level      STRING    COMMENT '等级（1:优秀，2:良，3:中等，4:不及格）',
              course_name      STRING    COMMENT '课程名称',
              course_code      STRING    COMMENT '课程编号',
              course_type      STRING    COMMENT '课程性质,参照enum_info中COURSETYPE类型的枚举，保存code',
              score      STRING    COMMENT '成绩',
              credit      STRING    COMMENT '学分',
              performance_point      STRING    COMMENT '绩点',
              category      STRING    COMMENT '课程类别:0理论,1实践,2理论加实践,99其他',
              course_attr      STRING    COMMENT '课程属性,参照enum_info中COURSEATTR类型的枚举，保存code',
              class_ranking      STRING    COMMENT '班级排名',
              major_ranking      STRING    COMMENT '专业排名',
              examination_type      STRING    COMMENT '1:正常，2：清考，3补考，4缓考 参考枚举表中examination_type'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'

        "

        fn_log "学生成绩明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}

#'RX', '任选'
#BX', '必修
#'XW', '学位'
#'XX', '限选'
#课程性质(任选,必修,学位,限选)怎么分？
# 绩点
#课程属性
# 课程类别:（0理论,1实践,2理论加实践）？课程里只有实践课，我把必修的课分到理论的里面了，理论加实践怎么分？
#成绩 里面有的（优秀，免休，留级，缓考等）字段信息，为什么不写到相应的字段里面呢？

function class_ranking_table() {
hive -e "DROP TABLE IF EXISTS tmp.class_ranking_table;"
hive -e "create table tmp.class_ranking_table as
            select
             a.XH,
             a.XQ,
             row_number () OVER (partition BY a.BH,a.XQ ORDER BY cj desc) as class_ranking
             from
            (select a.XQ,a.XH,b.BH,nvl(sum(a.cj),0) as cj
                from raw.sw_T_ZG_XSCJXX a
                left join raw.sw_t_bzks b
                on a.XH=b.XH where a.XN='${semester}'
                group by a.XQ,a.XH,b.BH) a
        "
        fn_log "导出数据--学生成绩班级排名表:tmp.class_ranking_table"
}
function major_ranking_table() {
hive -e "DROP TABLE IF EXISTS tmp.major_ranking_table;"
hive -e "create table tmp.major_ranking_table as
            select
             a.XH,
             a.XQ,
             row_number () OVER (partition BY a.ZYDM,a.XQ ORDER BY cj desc) as major_ranking
             from
            (select a.XQ,a.XH,b.ZYDM,nvl(sum(a.cj),0) as cj
                from raw.sw_T_ZG_XSCJXX a
                left join raw.sw_t_bzks b
                on a.XH=b.XH where a.XN='${semester}'
                group by a.XQ,a.XH,b.ZYDM) a
        "
        fn_log "导出数据--学生成绩专业排名表:tmp.class_ranking_table"
}
function import_table(){
        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
             nvl(a.XH,' ') as code,
             nvl(a.XN,' ')as semester_year,
             nvl(a.XQ,' ') as semester,
             nvl(case when a.CJ<60 then 4
                  when a.CJ>=60 and a.CJ<75 then 3
                  when a.CJ>=75 and a.CJ<85 then 2
                  else 1 end,' ') as level,
             nvl(b.KCZWMC,' ') as course_name,
             nvl(b.KCDM,' ') as course_code,
             nvl(case when b.KCXZ='必修课' then 'BX'
                  when b.KCXZ='公共选修课' then 'RX'
                  when b.KCXZ='专业选修课' then 'XX'
                  when b.KCXZ='实践课' then 'BX'
                  end,' ') as course_type,
              nvl(case when a.CJ='优秀' then 85
                   when a.CJ='免休' then 0
                   when a.CJ='留级' then 0
                   when a.CJ='缓考' then 0
                   when a.CJ='退学' then 0
                   when a.CJ='中等' then 75
                   when a.CJ='及格' then 60
                   when a.CJ='缺考' then 0
                   when a.CJ='不及格' then 59
                   when a.CJ='良好' then 79
                   else a.CJ end,0) as score,
              nvl(cast(b.XF as int),0) as credit,
              0 as performance_point,
              nvl(case when b.KCXZ='必修课' then 0
                   when b.KCXZ='实践课' then 1
                   else 99  end,' ') as category,
             ' ' as course_attr,
             c.class_ranking as class_ranking,
             d.major_ranking as major_ranking,
             nvl(case when a.CJ>60 or a.CJ=60  then 1
                  when a.CJ='及格' then 1
                  when a.CJ='优秀' then 1
                  when a.CJ='中等' then 1
                  when a.CJ='良好' then 1
                  when a.CJ<60 then 3
                  when a.CJ='缺考' then 3
                  when a.CJ='不及格' then 3
                  when a.CJ='缓考' then 4
                  else 2 end,' ') as examination_type
             from
             raw.sw_T_ZG_XSCJXX a
             left join raw.zgy_t_Zg_Jw_Kcjbxx b
             on a.KCBH=b.KCDM
             left join
             tmp.class_ranking_table c
             on a.XH=c.XH and a.XQ=c.XQ
             left join
             tmp.major_ranking_table d
             on a.XH=d.XH and a.XQ=d.XQ
             where a.XN='${semester}'

        "
        fn_log " 导入数据--学生成绩明细表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

        clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#        clear_mysql_data "delete from ${TARGET_TABLE} where semester_year='${semester}' ;"

        sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
        --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
        --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
        --null-string '\\N' --null-non-string '\\N'  \
        --columns "code,semester_year,semester,level,course_name,course_code,course_type,score,credit,performance_point,category,course_attr,class_ranking,major_ranking,examination_type"

        fn_log "导出数据--学生成绩明细表:${HIVE_DB}.${TARGET_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
    years=3
    for((i=1;i<=3;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      class_ranking_table
      major_ranking_table
      import_table

    done
}

#第一次执行create_table / getYearData /export_table:truncate table··· 循环近5年的
#第二次执行第一次执行create_table/import_table/export_table：delete from··· where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
##import_table
export_table
finish
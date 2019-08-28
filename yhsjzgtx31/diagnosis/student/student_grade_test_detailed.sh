#!/bin/sh
###################################################
###   基础表:      学生等级考试明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_grade_test_detailed.sh &
###  结果目标:      model.student_grade_test_detailed
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_grade_test_detailed

HIVE_DB=model
HIVE_TABLE=student_grade_test_detailed
TARGET_TABLE=student_grade_test_detailed
PRE_YEAR=`date +%Y`
SEMESTER_YEARS=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))
function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                        code   STRING     COMMENT '学生编号',
                        semester_year   STRING     COMMENT '学年',
                        semester   STRING     COMMENT '学期',
                        score   STRING     COMMENT '得分',
                        test_name   STRING     COMMENT '考试名称（pets4，pets6，ncre1，ncre2，ncre3）'        )COMMENT  '学生等级考试明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生等级考试明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

# pets6数据没有 计算机等级数据也很少，基本上是“计算机证”展示的
#考试名称分类（pets4，pets6，ncre1，ncre2，ncre3）高职院校的英语证书主要有英语AB级，四六级很少，
#这个分类要不要在加一下
function import_table(){

        hive -e "insert into table  ${HIVE_DB}.${HIVE_TABLE}
        select
        a.XH as code,
        a.XN as semester_year,
        substr(a.XQ,2,1) as semester,
        case when a.SCCJ is null then 0
             when a.SCCJ='优秀' then 85
             when a.SCCJ='合格' then 60
             when a.SCCJ='良好' then 75 else a.SCCJ  end  as score,
        case
            when a.ZSMC='计算机证' then 'ncre1' end test_name
        from
        raw.sw_T_ZG_XSZS a
        where a.ZSMC='计算机证'
        and  a.XN='${semester}'
        union all
        select
        a.XH as code,
        a.XN as semester_year,
        substr(a.XQ,2,1) as semester,
        case when a.SCCJ is null then 0
             when a.SCCJ='优秀' then 85
             when a.SCCJ='合格' then 60
             when a.SCCJ='良好' then 75 else a.SCCJ  end  as score,
        case
            when a.ZSMC='计算机一级证书' then 'ncre1'
            end test_name
        from
        raw.sw_T_ZG_XSZS a
        where a.ZSMC='计算机一级证书'
        and  a.XN='${semester}'
        union all
            select
            a.XH as code,
            a.XN as semester_year,
            substr(a.XQ,2,1) as semester,
            case when a.SCCJ is null then 0
                 when a.SCCJ='优秀' then 85
                 when a.SCCJ='合格' then 60
                 when a.SCCJ='良好' then 75 else a.SCCJ  end  as score,
            case
                when a.ZSMC='计算机二级证书' then 'ncre2'
                end test_name
            from
            raw.sw_T_ZG_XSZS a
            where a.ZSMC='计算机二级证书'
            and  a.XN='${semester}'
            union all
            select
            a.XH as code,
            a.XN as semester_year,
            substr(a.XQ,2,1) as semester,
            case when a.SCCJ is null then 0
                 when a.SCCJ='优秀' then 85
                 when a.SCCJ='合格' then 60
                 when a.SCCJ='良好' then 75 else a.SCCJ  end  as score,
            case when a.ZSMC='英语四级证' then 'pets4' end as test_name
            from
            raw.sw_T_ZG_XSZS a
            where a.ZSMC='英语四级证'
            and  a.XN='${semester}'
        "
        fn_log " 导入数据--学生等级考试明细表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#     clear_mysql_data "delete from ${TARGET_TABLE} where semester_year='${SEMESTER_YEARS}' ;"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,semester_year,semester,score,test_name"

    fn_log "导出数据--学生等级考试明细表: ${HIVE_DB}.${TARGET_TABLE}"

}
function getYearData(){
    vDate=`date +%Y`
    let vDate+=1;
    years=5
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
    done
}

#第一次执行create_table / getYearData /  循环近5年的  export_table:TRUNCATE``
#第二次执行create_table / import_table /  export_table:delete from ``       where后的变量改成 '${SEERMEST_YEARS}'`
init_exit
create_table
getYearData
#import_table
export_table
finish

#!/bin/sh
###################################################
###   基础表:      学生获取证书明细表
###   维护人:      shilipeng
###   数据源:
###   问题:

###  导入方式:      全量导入
###  运行频率:      每月一次
###################################################
cd `dirname $0`
source ../../config.sh
exec_dir student_papers

HIVE_DB=model
HIVE_TABLE=student_papers
TARGET_TABLE=student_papers

function create_table(){

        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
              academy_code      STRING    COMMENT '系部编号',
              major_code      STRING    COMMENT '专业编号',
              class_code      STRING    COMMENT '班级编号',
              code      STRING    COMMENT '学生编号',
              paper_code      STRING    COMMENT '证书编号',
              name      STRING    COMMENT '证书名称',
              papers_type      STRING    COMMENT '证书类型(1普通证书 2其他证书3资格证书)',
              get_time      STRING    COMMENT '获取时间(yyyy-mm-dd)',
              semester_year      STRING    COMMENT '学年',
              semester      STRING    COMMENT '学期',
              papers_level      STRING    COMMENT '资格证书类型 CJ：初级 ，ZJ：中级，GJ：高级 WD：无等级'
               )
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "学生获取证书明细表--'${HIVE_DB}.${HIVE_TABLE}'"
}
#证书类型 资格证书类型
#第一次into 以后overwrite
function import_table(){

        hive -e "
             INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
             select
                nvl(c.XBH,' ') as academy_code,
                nvl(b.ZYDM,' ') as major_code,
                nvl(b.BH,' ') as class_code,
                nvl(a.XH,' ')  as code,
                nvl(a.ZSBH,' ') as paper_code,
                nvl(a.ZSMC,' ') as name,
                ' ' as papers_type,
                nvl(a.FZRQ,' ') as get_time,
                nvl(a.XN,' ') as semester_year,
                nvl(substr(a.XQ,2,1),' ') as semester,
                ' ' as papers_level
             from
             raw.sw_T_ZG_XSZS a
             left join
             raw.sw_t_bzks b
             on a.XH=b.XH
             left join
             raw.zgy_t_zg_zyxx c
             on b.ZYDM=c.ZYDM
             where a.XN='${semester}'
        "
        fn_log " 导入数据--学生获取证书明细表:${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){

      clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#     clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year='${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,code,paper_code,name,papers_type,get_time,semester_year,semester,papers_level"

    fn_log "导出数据--学生获取证书明细表:${HIVE_DB}.${TARGET_TABLE}"

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

#第一次执行create_table / getYearData /export_table:truncate table··· 循环近5年的
#第二次执行第一次执行create_table/import_table/export_table：delete from··· where后的变量改成 '${SEERMEST_YEARS}'
init_exit
create_table
getYearData
#import_table
export_table
finish

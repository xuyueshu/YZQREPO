#!/bin/sh
###################################################
###   基础表:      科研项目人员明细表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_project_personnel_info.sh &
###  结果目标:      app.scientific_project_personnel_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir scientific_project_personnel_info

HIVE_DB=model
HIVE_TABLE=scientific_project_personnel_info
TARGET_TABLE=scientific_project_personnel_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '项目编号',
                                        teacher_code   STRING     COMMENT '人员工号',
                                        teacher_name   STRING     COMMENT '人员姓名',
                                        teacher_title   STRING     COMMENT '职称',
                                        project_funding   STRING     COMMENT '项目经费',
                                        membership_class   STRING     COMMENT '成员类别1主持，2参与',
                                        nuit_name   STRING     COMMENT '单位名称',
                                        order_signature   STRING     COMMENT '署名顺序',
                                        project_roles   STRING     COMMENT '项目角色',
                                        contribution_rate   STRING     COMMENT '贡献率',
                                        annual_workload   STRING     COMMENT '年度工作量',
                                        semester_year   STRING     COMMENT '学年',
                                        is_sub_topic   STRING     COMMENT '是否子课题:1是，0或其他为否',
                                        project_type   STRING     COMMENT '项目成员类别（1：纵向项目，2横向项目）')COMMENT  '科研项目人员明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--科研项目人员明细表: ${HIVE_DB}.${HIVE_TABLE}"
}
#成员类别 署名顺序 项目角色 贡献率 年度工作量 是否子课题
function import_table(){
    hive -e "
    INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
    select
    b.code,
    b.teacher_code,
    b.teacher_name,
    b.teacher_title,
    b.project_funding,
    b.membership_class,
    b.nuit_name,
    b.order_signature,
    b.project_roles,
    b.contribution_rate,
    b.annual_workload,
    b.semester_year,
    b.is_sub_topic,
    b.project_type
    from
    (
    select
    a.PROJECT_NO as code,
    a.FUNCTIONARY_NO as teacher_code,
    a.FUNCTIONARY_NAME as teacher_name,
    b.ZYJSZWDM as teacher_title,
    a.RESEARCH_MONEY as project_funding,
    '' as membership_class,
    '陕西能源职业技术学院' as nuit_name,
    '' as order_signature,
     ''  as project_roles,
     '' as contribution_rate,
     '' as annual_workload,
    case
			when substr(a.START_DATE,5,1)=0 and substr(a.START_DATE,6,1)<7 then concat(cast(substr(a.START_DATE,1,4)-1 as int),'-',substr(a.START_DATE,1,4))
			when substr(a.START_DATE,5,1)=0 and substr(a.START_DATE,6,1)>7 then concat(substr(a.START_DATE,1,4),'-',cast(substr(a.START_DATE,1,4)+1 as int))
			when substr(a.START_DATE,5,1)!=0 and substr(a.START_DATE,5,2)>7 then concat(substr(a.START_DATE,1,4),'-',cast(substr(a.START_DATE,1,4)+1 as int))
	end as semester_year,
    '' as is_sub_topic,
     case when a.PROJECT_TYPE='横向'  then 2 when a.PROJECT_TYPE='纵向'  then 1 end     as project_type
    from raw.sr_T_KY_KYXMXX a
    left join
     raw.hr_t_jzg b
     on
     a.FUNCTIONARY_NO=b.ZGH
     ) b where b.semester_year='${semester}'
    "
    }

function export_table(){
   clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#    clear_mysql_data "delete from ${TARGET_TABLE} where semester_year='${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,teacher_code,teacher_name,teacher_title,project_funding,membership_class,nuit_name,order_signature,project_roles,contribution_rate,annual_workload,semester_year,is_sub_topic,project_type"

    fn_log "导出数据--科研项目人员明细表: ${HIVE_DB}.${TARGET_TABLE}"

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
    done
}

#第一次执行create_table--getYearData / export_table   循环近5年的  export_table:TRUNCATE TABLE```
#第二+以后次执行import_table / export_table where后的变量改成 '${SEMESTER_YEARS}'  export_table:delete from ```
init_exit
create_table
getYearData
#import_table
export_table
finish
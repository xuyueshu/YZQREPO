#!/bin/sh
###################################################
###   基础表:      教师课题项目统计表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_project_count.sh &
###  结果目标:      app.teacher_project_count
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_project_count

HIVE_DB=model
HIVE_TABLE=teacher_project_count
TARGET_TABLE=teacher_project_count

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '三级部门编号',
                                        major_code   STRING     COMMENT '专业编号',
                                        project_name   STRING     COMMENT '课题名称',
                                        amount   STRING     COMMENT '课题到款额(万元)',
                                        project_type   STRING     COMMENT '课题类型(1纵向科研课题 2横向科研课题)',
                                        semester_year   STRING     COMMENT '学年',
                                        major_name   STRING     COMMENT '专业的名称',
                                        academy_name   STRING     COMMENT '三级部门名称',
                                        dept_code   STRING     COMMENT '二级部门编号',
                                        dept_name   STRING     COMMENT '二级部门名称'        )COMMENT  '教师课题项目统计表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师课题项目统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select
                '' academy_code,
                '' major_code,
                a.PROJECT_NAME project_name,
                nvl(b.ARRIVAL_CASH,0) amount,
                case when a.PROJECT_TYPE like '%纵向%' then 1 when PROJECT_TYPE like '%横向%' then 2 else 0 end project_type,
                case when length(a.SETUP_DATE)=6 then concat(cast(substring(a.SETUP_DATE,1,4) as int),'-',cast(substring(a.SETUP_DATE,1,4) as int)+1)
                     else concat(cast(concat('20',substring(a.PROJECT_NO,1,2)) as int),'-',cast(concat('20',substring(a.PROJECT_NO,1,2)) as int)+1) end semester_year,
                '' major_name,
                '' academy_name,
                nvl(c.SZKSDM,'') dept_code,
                nvl(d.dwmc,'') dept_name
        from raw.sr_t_ky_kyxmxx a
        left join raw.sr_T_KY_KYDKQK b on a.PROJECT_NO=b.PROJECT_CODE
        left join raw.hr_t_jzg  c on a.FUNCTIONARY_NO=c.zgh
        left join raw.pm_t_xx_dw d on c.SZKSDM=d.dwdm

        "
        fn_log " 导入数据--教师课题项目统计表: ${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,project_name,amount,project_type,semester_year,major_name,academy_name,dept_code,dept_name"

    fn_log "导出数据--教师课题项目统计表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
#!/bin/sh
###################################################
###   基础表:      学生生源地贷款信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh student_birthplace_loan_record.sh &
###  结果目标:      model.student_birthplace_loan_record
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir student_birthplace_loan_record

HIVE_DB=model
HIVE_TABLE=student_birthplace_loan_record
TARGET_TABLE=student_birthplace_loan_record

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        academy_code   STRING     COMMENT '系部编号',
                                        major_code   STRING     COMMENT '专业编号',
                                        class_code   STRING     COMMENT '班级编号',
                                        code   STRING     COMMENT '学生编号',
                                        loan_amount   STRING     COMMENT '贷款金额',
                                        contract_no   STRING     COMMENT '合同编号',
                                        managing_bank   STRING     COMMENT '经办银行',
                                        sign_the_annual   STRING     COMMENT '签署年度(yyyy)',
                                        load_age_limit   STRING     COMMENT '贷款年限',
                                        phone   STRING     COMMENT '联系方式',
                                        origin_of_student   STRING     COMMENT '生源地',
                                        repayment_amount   STRING     COMMENT '还款总额(元)',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '学生生源地贷款信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学生生源地贷款信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select nvl(c.XBH,' ') as academy_code,
                nvl(b.ZYDM,' ') as major_code,
                nvl(b.BH,' ') as class_code,
                nvl(a.XH,' ')  as code,
                nvl(c.ZJE,' ') as loan_amount,
                nvl(c.DKHTH,' ') as contract_no,
                nvl(c.JBYHHDW,' ') as managing_bank,
                as sign_the_annual,
                as load_age_limit,
                as phone,
                .SYDDM as origin_of_student,

                 nvl(a.XN,' ') as semester_year,"
        fn_log " 导入数据--学生生源地贷款信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "academy_code,major_code,class_code,code,loan_amount,contract_no,managing_bank,sign_the_annual,load_age_limit,phone,origin_of_student,repayment_amount,semester_year"

    fn_log "导出数据--学生生源地贷款信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
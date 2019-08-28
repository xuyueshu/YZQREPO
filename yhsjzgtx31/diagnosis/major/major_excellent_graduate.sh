#!/bin/sh
###################################################
###   基础表:      专业优秀毕业生信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh major_excellent_graduate.sh &
###  结果目标:      model.major_excellent_graduate
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir major_excellent_graduate

HIVE_DB=model
HIVE_TABLE=major_excellent_graduate
TARGET_TABLE=major_excellent_graduate

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '学号',
                                        name   STRING     COMMENT '姓名',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称',
                                        cademary_code   STRING     COMMENT '院系编号',
                                        cademary_name   STRING     COMMENT '院系名称',
                                        educational_system   STRING     COMMENT '学制(3年或5年)',
                                        class_name   STRING     COMMENT '班级名称',
                                        sex   STRING     COMMENT '性别:1男 2女 0其他',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '专业优秀毕业生信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--专业优秀毕业生信息表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
      select
            aa.xh code,
            aa.XM name,
            substr(bb.zydm,1,6) major_code,
            d.zymc major_name,
            bb.dwdm as cademary_code,
            e.dwmc as cademary_name,
            case when bb.xzdm is null then 5 else cast(bb.xzdm as int) end educational_system,
            f.bjmc class_name,
            bb.xbdm sex,
            aa.xnmc semester_year
        from
            (   select *
                from raw.oe_t_zg_xsbyxx a ,(
                select XN,XH as code from raw.sw_T_ZG_XSCJXX
                group by XN,XH
                having avg(cj)>=85
                ) b
                where a.xnmc=b.xn and a.xh=b.code
            ) aa left join raw.sw_T_BZKS bb on aa.xh=bb.xh
            left join (select zydm,zymc from raw.zgy_t_zg_zyxx group by zydm,zymc) d on substr(bb.zydm,1,6)=substr(d.zydm,1,6)
            left join raw.pm_t_xx_dw e on bb.dwdm=e.dwdm
            left join raw.te_t_bzks_bjap f on bb.bh=f.bh
        "
        fn_log " 导入数据--专业优秀毕业生信息表: ${HIVE_DB}.${HIVE_TABLE}"

}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,major_code,major_name,cademary_code,cademary_name,educational_system,class_name,sex,semester_year"

    fn_log "导出数据--专业优秀毕业生信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
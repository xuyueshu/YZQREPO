#!/bin/sh
###################################################
###   基础表:      科研团队明细表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_team_info.sh &
###  结果目标:      app.scientific_team_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir scientific_team_info

HIVE_DB=model
HIVE_TABLE=scientific_team_info
TARGET_TABLE=scientific_team_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '科研团队编号',
                                        teacher_code   STRING     COMMENT '负责人编号',
                                        teacher_name   STRING     COMMENT '负责人姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        name   STRING     COMMENT '科研团队名称'        )COMMENT  '科研团队明细表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--科研团队明细表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){

        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}"
        fn_log " 导入数据--科研团队明细表: ${HIVE_DB}.${HIVE_TABLE}"

}



init_exit
create_table
import_table
finish
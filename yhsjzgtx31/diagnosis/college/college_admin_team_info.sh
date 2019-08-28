#!/bin/sh
###################################################
###   基础表:      学院管理队伍详情表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_admin_team_info.sh &
###  结果目标:      model.college_admin_team_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_admin_team_info

HIVE_DB=model
HIVE_TABLE=college_admin_team_info
TARGET_TABLE=college_admin_team_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        teacher_code   STRING     COMMENT '教师编号',
                                        leader_type   STRING     COMMENT '管理队伍类型：参见enum_info中GLLX类型的枚举，保存对应code',
                                        age   STRING     COMMENT '管理队伍年龄',
                                        title_type   STRING     COMMENT '管理队伍教师职称：参见enum_info中ZCJG类型的枚举，保存对应code',
                                        education   STRING     COMMENT '管理队伍教师学历',
                                        education_type   STRING     COMMENT '管理队伍教师学历：参见enum_info中XLJG类型的枚举，保存对应code',
                                        sex   STRING     COMMENT '性别:1男 2女 0其他',
                                        semester_year   STRING     COMMENT '学年'        )COMMENT  '学院管理队伍详情表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院管理队伍详情表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            SELECT distinct
                a.jzgbh teacher_code,
                case when zwmc like '%处长%' then 'CZGB'
                     when zwmc like '%科长%' then 'KZGB'
                     else 'QT' end leader_type,
                cast(substr(CURRENT_DATE,1,4) as int )-cast(substr(b.CSNY,1,4) as int ) age,
                case  when c.ZYJSZWJB like '%正高%' then 'ZGZC'
                      when c.ZYJSZWJB like '%副高%' then 'FGZC'
                      when c.ZYJSZWJB like '%中%' then 'ZJZC'
                      else 'CJZC'  end title_type,
                case  when trim(b.ZGXLDM) = '14' or trim(b.ZGXLDM) ='15' or trim(b.ZGXLDM) ='16' then '研究生'
                      when trim(b.ZGXLDM)='21' or trim(b.ZGXLDM)= '22' or trim(b.ZGXLDM) ='23' then '本科'
                      when trim(b.ZGXLDM)='31' or trim(b.ZGXLDM)='32' or trim(b.ZGXLDM) ='33' then '大专'
                      when trim(b.ZGXLDM)='11' or trim(b.ZGXLDM)='12' or trim(b.ZGXLDM) ='13' then '研究生'
                      when cast(trim(b.ZGXLDM) as int)>=40 then '中专'
                      else '本科' end education,
                case  when trim(b.ZGXLDM) = '14' or trim(b.ZGXLDM) ='15' or trim(b.ZGXLDM) ='16' then 'YJS'
                      when trim(b.ZGXLDM)='21' or trim(b.ZGXLDM)= '22' or trim(b.ZGXLDM) ='23' then 'BK'
                      when trim(b.ZGXLDM)='31' or trim(b.ZGXLDM)='32' or trim(b.ZGXLDM) ='33' then 'ZK'
                      when trim(b.ZGXLDM)='11' or trim(b.ZGXLDM)='12' or trim(b.ZGXLDM) ='13' then 'YJS'
                      when cast(trim(b.ZGXLDM) as int)>=40 then 'ZZ'
                       else 'BK' end  education_type,
                nvl(XBDM,'0') sex,
                '${semester}' semester_year
            FROM raw.pm_t_jzg_zwjl a
            LEFT JOIN raw.hr_t_jzg b on a.jzgbh=b.zgh
            LEFT JOIN raw.te_t_jzg_jzcjl c on a.jzgbh=c.jzgbh
        "
        fn_log " 导入数据--学院管理队伍详情表: ${HIVE_DB}.${HIVE_TABLE}"

}



function export_table(){
     clear_mysql_data "delete from  ${TARGET_TABLE} where semester_year = '${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "teacher_code,leader_type,age,title_type,education,education_type,sex,semester_year"

    fn_log "导出数据--学院管理队伍详情表: ${HIVE_DB}.${TARGET_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    years=5
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
      export_table
    done
}

init_exit
create_table
getYearData
#export_table
finish
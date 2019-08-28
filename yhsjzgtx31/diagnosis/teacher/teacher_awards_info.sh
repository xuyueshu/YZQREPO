#!/bin/sh
###################################################
###   基础表:      师资获奖表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_awards_info.sh &
###  结果目标:      app.teacher_awards_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_awards_info

HIVE_DB=model
HIVE_TABLE=teacher_awards_info
TARGET_TABLE=teacher_awards_info

PRE_YEAR=`date +%Y`
SEMESTER_YEAR=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        awards_time   STRING     COMMENT '获奖时间',
                                        awards_type   STRING     COMMENT '1国家级，2省部级，3市级，0其他',
                                        awards_name   STRING     COMMENT '获奖名称 查看枚举表JSHJMC',
                                        remark   STRING     COMMENT '备注',
                                        dept_code   STRING     COMMENT '',
                                        dept_name   STRING     COMMENT '',
                                        title   STRING     COMMENT '职称',
                                        major_code   STRING     COMMENT '专业编号',
                                        major_name   STRING     COMMENT '专业名称'        )COMMENT  '师资获奖表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--师资获奖表: ${HIVE_DB}.${HIVE_TABLE}"
}
#缺少院系和专业信息
function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
            select
                a.GH code,
                a.XM name,
                case when XN is null then '${SEMESTER_YEAR}' else
                concat(cast(XN as int)-1,'-',XN) end semester_year,
                case when a.HJSJ is null then '' else
                if(
                    substr(
                      trim(a.HJSJ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.HJSJ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.HJSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.HJSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.HJSJ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.HJSJ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.HJSJ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.HJSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.HJSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.HJSJ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.HJSJ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) end as awards_time,
                case when HJJB like '%国家%' then 1
                when  HJJB like '%省%' then 2 when  HJJB like '%市%' then 3 else 0 end  awards_type,
                case when  HJMC like '%技能%' then 'ZYJNJSHJ'
                    when HJMC like '%教学质量%' then 'JXZLGCHJ' when HJMC like '%教学%' then 'JXNLBSHJ' else 'QT' end awards_name,
                nvl(HJMC,'') remark,
                nvl(b.szdwdm,'') dept_code,
                nvl(d.dwmc,'') dept_name,
                c.ZYJSZW title,
                '' major_code,
                '' major_name
            from raw.pm_t_jzg_hjxx a
            left join raw.hr_t_jzg b on a.gh=b.ZGH
            left join raw.pm_t_xx_dw d on b.szdwdm=d.dwdm
            left join raw.te_t_jzg_jzcjl c on a.gh=c.JZGBH

        "
        fn_log " 导入数据--学院教学质量信息表: ${HIVE_DB}.${HIVE_TABLE}"

}


function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester_year,awards_time,awards_type,awards_name,remark,dept_code,dept_name,title,major_code,major_name"

    fn_log "导出数据--师资获奖表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
export_table
finish
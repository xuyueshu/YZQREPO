#!/bin/sh
###################################################
###   基础表:      教师成长表
###   维护人:      guojianing
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh teacher_growing_info.sh &
###  结果目标:      app.teacher_growing_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir teacher_growing_info

HIVE_DB=model
HIVE_TABLE=teacher_growing_info
TARGET_TABLE=teacher_growing_info

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        code   STRING     COMMENT '教师编号',
                                        name   STRING     COMMENT '教师姓名',
                                        semester_year   STRING     COMMENT '学年',
                                        growing_type   STRING     COMMENT '1培训，2进修，3学历提升，4社会兼职，5企业实践，6其他',
                                        level   STRING     COMMENT '培训——1海外研修、2国内培训、3校内培训；
企业实践——1长期、2短期；
进修、访学、会议交流——0暂无',
                                        growing_name   STRING     COMMENT '详细说明',
                                        remark   STRING     COMMENT '备注',
                                        start_time   STRING     COMMENT '开始时间（yyyy-mm-dd）',
                                        end_time   STRING     COMMENT '结束时间（yyyy-mm-dd）',
                                        dept_code   STRING     COMMENT '系编码',
                                        dept_name   STRING     COMMENT '系名称',
                                        major_code   STRING     COMMENT '专业编码',
                                        major_name   STRING     COMMENT '专业名称',
                                        prize_type  STRING     COMMENT '培训荣誉证书' )COMMENT  '教师成长表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--教师成长表: ${HIVE_DB}.${HIVE_TABLE}"
}

function import_table(){
        hive -e "insert overwrite table  ${HIVE_DB}.${HIVE_TABLE}
        select  distinct
                nvl(jscz.code,'') code,
                nvl(jscz.name,'') name,
                nvl(jscz.semester_year,'') semester_year,
                nvl(jscz.growing_type,'') growing_type,
                nvl(jscz.level,'') level,
                nvl(jscz.growing_name,'') growing_name,
                nvl(jscz.remark,'') remark,
                nvl(jscz.start_time,'') start_time,
                nvl(jscz.end_time,'') end_time,
                nvl(jscz.dept_code,'') dept_code,
                nvl(jscz.dept_name,'') dept_name,
                nvl(jscz.major_code,'') major_code,
                nvl(jscz.major_name,'') major_name,
                '' as prize_type
            from (
                select
                        a.gh as code,
                  a.xm as name,
                  case when a.xn is null then '' else concat(cast(a.xn as int),'-',cast(a.xn as int)+1) end as semester_year,
                  1 as growing_type,
                  2 as level,
                  a.PXXMMC as growing_name,
                  a.PXXMMC as remark,
                  if(
                    substr(
                      trim(a.PXKSRQ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.PXKSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.PXKSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.PXKSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.PXKSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.PXKSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.PXKSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.PXKSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.PXKSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.PXKSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.PXKSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as start_time,
                  if(
                    substr(
                      trim(a.PXJSRQ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.PXJSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.PXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.PXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.PXJSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.PXJSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.PXJSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.PXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.PXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.PXJSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.PXJSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as end_time,
                  b.YBDM dept_code,
                  b.SSYB dept_name,
                  b.ZYDM major_code,
                  b.GSZY major_name
                  from raw.pm_t_jzg_pxxx a
                  left join raw.PM_T_ZG_JSZYGS b on a.gh=b.ZGH

              union all

                select
                        a.gh as code,
                  a.xm as name,
                  case when a.KSRQ is null then '' else concat(cast(concat('20',substr(trim(a.KSRQ),8,2)) as int),'-',cast(concat('20',substr(trim(a.KSRQ),8,2)) as int)+1) end as semester_year,
                  case when trim(JZLX)='社会兼职' then 4 when trim(JZLX)='企业实践' then 5 else 6 end as growing_type,
                  case when a.ZTS<60 then 2 else 1 end as level,
                  a.JZMC as growing_name,
                  a.JZMC as remark,
                  if(
                    substr(
                      trim(a.KSRQ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.KSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.KSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.KSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.KSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.KSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.KSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.KSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.KSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.KSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.KSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as start_time,
                  if(
                    substr(
                      trim(a.JSRQ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.JSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.JSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.JSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.JSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.JSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.JSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.JSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.JSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.JSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.JSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as end_time,
                  b.YBDM dept_code,
                  b.SSYB dept_name,
                  b.ZYDM major_code,
                  b.GSZY major_name
                  from raw.pm_t_jzg_shjz a
                  left join raw.PM_T_ZG_JSZYGS b on a.gh=b.ZGH

              union all

                select
                        a.gh as code,
                  a.xm as name,
                  case when a.HQSJ is null then '' else concat(cast(concat('20',substr(trim(a.HQSJ),8,2)) as int),'-',cast(concat('20',substr(trim(a.HQSJ),8,2)) as int)+1) end as semester_year,
                  3 as growing_type,
                  0 as level,
                  a.MS as growing_name,
                  a.MS as remark,
                  if(
                    substr(
                      trim(a.HQSJ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.HQSJ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.HQSJ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.HQSJ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.HQSJ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.HQSJ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.HQSJ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as start_time,
                  if(
                    substr(
                      trim(a.HQSJ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.HQSJ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.HQSJ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.HQSJ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.HQSJ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.HQSJ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.HQSJ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.HQSJ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as end_time,
                  b.YBDM dept_code,
                  b.SSYB dept_name,
                  b.ZYDM major_code,
                  b.GSZY major_name
                  from raw.pm_t_jzg_jcfznl a
                  left join raw.PM_T_ZG_JSZYGS b on a.gh=b.ZGH
                ) jscz
        "
        fn_log " 导入数据--教师成长表: ${HIVE_DB}.${HIVE_TABLE}"
}


function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "code,name,semester_year,growing_type,level,growing_name,remark,start_time,end_time,dept_code,dept_name,major_code,major_name"

    fn_log "导出数据--教师成长表: ${HIVE_DB}.${TARGET_TABLE}"

}

init_exit
create_table
import_table
#export_table
finish
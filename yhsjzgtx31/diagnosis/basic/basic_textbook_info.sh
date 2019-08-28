#!/bin/sh
#################################################
###  基础表:       专业主编教材信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_textbook_info.sh [&]
###  结果目标:      model.basic_textbook_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_textbook_info

HIVE_DB=model
HIVE_TABLE=basic_textbook_info
TARGET_TABLE=basic_textbook_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
        course_code  STRING COMMENT '课程代码',
        course_name  STRING COMMENT '课程名称',
        major_code STRING COMMENT'专业代码',
        major_name STRING COMMENT'专业名称',
        academy_code STRING COMMENT'院系代码',
        academy_name STRING COMMENT'院系名称',
        textbook_name STRING COMMENT'教材名称',
        author STRING COMMENT'第一作者',
        is_education_planning STRING COMMENT'是否教育部规划教材(1是,2否)',
        is_education_good STRING COMMENT'是否教育部精品教材(1是,2否)',
        is_industry_compilation STRING COMMENT'是否行业部委统编教材(1是,2否)',
        is_enterprise_cooperation STRING COMMENT'是否校企合作开发教材(1是,2否)',
        is_self_designed STRING COMMENT'是否自编教材(1是,2否)',
        is_handouts STRING COMMENT'是否讲义(1是,2否)',
        type STRING COMMENT'教材类型:高职高专，本科及以上，中专，其他(参见emnu_info中JCLX类型的枚举，保存对应code)',
        semester_year STRING COMMENT'学年',
        textbook_code STRING COMMENT'教材编号',
        semester STRING COMMENT'学期'
    ) COMMENT '专业主编教材信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表--专业主编教材信息表：${HIVE_DB}.${HIVE_TABLE}"
}
#XQHZ', '校企合作开发教材
#ZBJC', '自编教材'
#JY', '讲义
#QT', '其他'
function pm_teacher_write_textbooks_info(){
    hive -e "DROP TABLE IF EXISTS tmp.pm_teacher_write_textbooks_info;"
    hive -e "create table tmp.pm_teacher_write_textbooks_info as
                select
                  concat(substr(a.xn,1,4),'-',substr((substr(a.xn,1,4)+1),1,4)) as academic_year_name,
                  case when a.xq is null then '1' else cast(a.xq as int) end as semester_name,
                  a.gh as teacher_code,
                  a.xm as teacher_name,
                  cast(a.JCBH as int) as textbook_code,
                  a.JCMC as textbook_name,
                  a.KCMC as course_name,
                  cast(a.KCBH as int) as course_code,
                  if(
                    substr( trim(a.KSBXRQ),8, 2 )> 20,
                    concat( '19',substr( trim(a.KSBXRQ), 8, 2 ), '-',if(split(split(trim(a.KSBXRQ),'月') [0],'-') [1] > 9,split(
                          split(trim(a.KSBXRQ),'月') [0],'-') [1],concat('0',split(
                            split(trim(a.KSBXRQ),'月') [0],'-') [1])),'-',split(split(trim(a.KSBXRQ),'月') [0],'-'
                      ) [0]),concat(
                      '20', substr(trim(a.KSBXRQ),8,2),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.KSBXRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.KSBXRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.KSBXRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.KSBXRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as start_date,
                  if(
                    substr(
                      trim(a.BXJSRQ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.BXJSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.BXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.BXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.BXJSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.BXJSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.BXJSRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.BXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.BXJSRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.BXJSRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.BXJSRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as end_date,
                  if(
                    substr(
                      trim(a.CBRQ),
                      8,
                      2
                    )> 20,
                    concat(
                      '19',
                      substr(
                        trim(a.CBRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.CBRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.CBRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.CBRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.CBRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    ),
                    concat(
                      '20',
                      substr(
                        trim(a.CBRQ),
                        8,
                        2
                      ),
                      '-',
                      if(
                        split(
                          split(
                            trim(a.CBRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1] > 9,
                        split(
                          split(
                            trim(a.CBRQ),
                            '月'
                          ) [0],
                          '-'
                        ) [1],
                        concat(
                          '0',
                          split(
                            split(
                              trim(a.CBRQ),
                              '月'
                            ) [0],
                            '-'
                          ) [1]
                        )
                      ),
                      '-',
                      split(
                        split(
                          trim(a.CBRQ),
                          '月'
                        ) [0],
                        '-'
                      ) [0]
                    )
                  ) as publish_date,
                  a.CBS as press,
                  a.FS as score,
                  case when a.SFHJ = '是' then 1 else 2 end as is_reward,
                  case when a.HJLX = '国家规划教材' then 1 when a.HJLX = '省级优秀教材' then 2 else 3 end as reward_type,
                  case when a.JCLX = '校本教材' then 1 when a.JCLX = '普通公开出版教材' then 2 else 3 end as textbook_type,
                  if(a.BXLX = '主编', 1, 2) as write_type,
                  from_unixtime(
                    unix_timestamp(),
                    'yyyyMMddHHmmss'
                  ) AS create_time
                from raw.pm_t_jzg_kyzz a
                  "

}
function import_data() {
    hive -e "
        INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
        b.course_code,
        b.course_name,
        b.major_code,
        b.major_name,
        b.academy_code,
        b.academy_name,
        b.textbook_name,
        b.author,
        b.is_education_planning,
        b.is_education_good,
        b.is_industry_compilation,
        b.is_enterprise_cooperation,
        b.is_self_designed,
        b.is_handouts,
        b.type,
        b.semester_year,
        b.textbook_code,
        b.semester
        from
        (
        select
        distinct
        row_number() OVER(
                        PARTITION BY a.KBKCDM,b.textbook_name
                      ) as num,
        a.KBKCDM as course_code,
        a.KBKCMC as course_name,
        a.ZYDM as major_code,
        a.ZYMC as major_name,
        a.XYDM as academy_code,
        a.XYMC as academy_name,
        b.textbook_name as textbook_name,
        b.teacher_code as author,
        cast(case when b.reward_type='1' then 1 else 0 end  as int) as is_education_planning,
        cast(2 as int) as is_education_good,
        cast(2 as int) as is_industry_compilation,
        cast(2 as int) as is_enterprise_cooperation,
        cast(case when b.textbook_type='1' then 1 else 2 end as int) as is_self_designed,
        cast(2 as int) as is_handouts,
        case when b.textbook_type='1' then 'ZBJC' else 'YBGH' end type,
          b.academic_year_name as semester_year,
          b.textbook_code as textbook_code,
          case when b.semester_name is null then 1 else b.semester_name end as semester
          from
        raw.zgy_T_ZG_JSKB a left join
        tmp.pm_teacher_write_textbooks_info b
        on a.KBKCDM=b.course_code
        where b.academic_year_name='${semester}'
        ) b where num =1

        union all

        select
            xx.KCBH as course_code,
            xx.KCMC as course_name,
            xx.SYZYBH major_code,
            xx.SYZYMC major_name,
            xx.XBDM academy_code,
            xx.XBMC academy_name,
            xx.KCMC textbook_name,
            '' author,
            1 is_education_planning,
            2 is_education_good,
            1 is_industry_compilation,
            1 is_enterprise_cooperation,
            1 is_self_designed,
            2 is_handouts,
            'XQHZ' type,
            xl.semester_year semester_year,
            xx.KCBH textbook_code,
            xl.semester semester
        from raw.ec_t_zg_xqhzkfkcxx xx ,model.basic_semester_info xl
        where xx.KFRQ>=xl.begin_time and xx.KFRQ<=xl.end_time
        and cast(substring(xx.kfrq,1,4) as int)='${NOW_YEAR}'
    "
    fn_log "导入数据--专业主编教材信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_data() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "course_code,course_name,major_code,major_name,academy_code,academy_name,textbook_name,
    author,is_education_planning,is_education_good,is_industry_compilation,is_enterprise_cooperation,
    is_self_designed,is_handouts,type,semester_year,textbook_code,semester"
    fn_log "导出数据--专业主编教材信息表:${HIVE_DB}.${TARGET_TABLE}"
}


function getYearData(){
    vDate=`date +%Y`
    let vDate+=1;
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
     import_data


    done
}

init_exit
#pm_teacher_write_textbooks_info
create_table
#临时表
pm_teacher_write_textbooks_info
getYearData
export_data
finish


#创建教师主编或参编教材信息表临时表
#academic_year_name STRING COMMENT '学年',
#                semester_name STRING COMMENT '学期 格式 1 或者 2',
#				teacher_code  STRING COMMENT '教师编号',
#				teacher_name  STRING COMMENT '教师姓名',
#				textbook_code STRING COMMENT '教材编号',
#				textbook_name STRING COMMENT '编写教材名称',
#				course_name STRING COMMENT '课程名称',
#                course_code STRING COMMENT '课程编号',
#				start_date DATE COMMENT '开始编写日期',
#				end_date DATE COMMENT '编写结束日期' ,
#				publish_date DATE COMMENT '出版日期' ,
#				press STRING COMMENT '出版社',
#				score DECIMAL(10,2) COMMENT '分数',
#				is_reward TINYINT COMMENT'是否获奖 1:是 2:否',
#				reward_type TINYINT COMMENT'获奖类型  1:国家规划教材  2:省级优秀教材  3:院级优秀教材',
#				textbook_type TINYINT COMMENT '教材类型:1.校本教材,2.普通公开出版教材,3.国家规划教材',
#				write_type TINYINT COMMENT '编写类型:1.主编,2.参编',
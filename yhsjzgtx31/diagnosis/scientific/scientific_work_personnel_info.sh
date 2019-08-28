#!/bin/sh
#################################################
###  基础表:       科研著作人员明细表
###  维护人:       guojianing
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh scientific_work_personnel_info.sh. &
###  结果目标:      model.scientific_work_personnel_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir scientific_work_personnel_info

HIVE_DB=model
HIVE_TABLE=scientific_work_personnel_info
TARGET_TABLE=scientific_work_personnel_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
	              code STRING COMMENT '著作编号',
                  teacher_code STRING COMMENT '人员工号',
                  teacher_name STRING COMMENT '作者姓名',
                  order_signature STRING COMMENT '署名顺序',
                  author_type STRING COMMENT '作者类型1位主编，2位参编',
                  author_unit STRING COMMENT '作者单位',
                  contribution_rate STRING COMMENT '贡献率',
                  assume_role STRING COMMENT '承担角色',
                  semester_year STRING COMMENT '学年'
      )COMMENT '科研著作人员明细表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--科研著作人员明细表:${HIVE_DB}.${HIVE_TABLE}"
}
#创建教师主编或参编教材信息表临时表
#academic_year_name '学年',
#semester_name '学期 格式 1 或者 2',
#teacher_code  '教师编号',
#teacher_name   '教师姓名',
#textbook_code  '教材编号',
#textbook_name '编写教材名称',
#course_name '课程名称',
#course_code '课程编号',
#start_date '开始编写日期',
#end_date  '编写结束日期' ,
#publish_date  '出版日期' ,
#press S'出版社',
#score  '分数',
#is_reward '是否获奖 1:是 2:否',
#reward_type 获奖类型  1:国家规划教材  2:省级优秀教材  3:院级优秀教材',
#textbook_type  '教材类型:1.校本教材,2.普通公开出版教材,3.国家规划教材',
#write_type  '编写类型:1.主编,2.参编',
function pm_teacher_write_textbooks_info(){
    hive -e "create table tmp.pm_teacher_write_textbooks_info as
                select
                  concat(substr(a.xn,1,4),'-',substr((substr(a.xn,1,4)+1),1,4)) as academic_year_name,
                  cast(a.xq as int) as semester_name,
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
                from
                  raw.pm_t_jzg_kyzz a"

}
function import_table(){
    hive -e "
        INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
			 a.textbook_code as code,
			 a.teacher_code as teacher_code ,
			 a.teacher_name as teacher_name,
		     '' as order_signature,
			 cast(a.write_type as int) author_type,
			 b.second_dept_code as author_unit,
			 ''  as contribution_rate,
			 case when a.write_type='1' then '主编' when a.write_type='2' then '参编' end as  assume_role,
			 a.academic_year_name as semester_year
			 from
			 tmp.pm_teacher_write_textbooks_info a left join model.basic_teacher_info b
             on a.teacher_code=b.code
             where a.academic_year_name='${semester}'"
    fn_log "导入数据--科研著作人员明细表 :${HIVE_DB}.${HIVE_TABLE}"
}

function export_data() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
#    clear_mysql_data "delete from TABLE ${TARGET_TABLE} where semester_year='${semester}';"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,teacher_code,teacher_name,order_signature,author_type,author_unit,contribution_rate,
    assume_role,semester_year"
    fn_log "导出数据--科研著作人员明细表:${HIVE_DB}.${TARGET_TABLE}"
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

init_exit
#第一执行  临时表 /create_table/ getYearData  export_data:truncate table```
#第二次以后执行 临时表 / import_table / export_data   export_data:delete from ```
#临时表
#pm_teacher_write_textbooks_info
create_table
getYearData
#import_table
export_data
finish
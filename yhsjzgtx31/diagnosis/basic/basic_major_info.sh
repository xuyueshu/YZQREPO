#!/bin/sh
#################################################
###  基础表:       专业基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_major_info.sh. &
###  结果目标:      model.basic_major_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_major_info

HIVE_DB=model
HIVE_TABLE=basic_major_info
TARGET_TABLE=basic_major_info
PRE_YEAR=`date +%Y`
SEMESTER_YEAR=$((${PRE_YEAR} - 1))"-"${PRE_YEAR}
function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            code STRING COMMENT '专业代码',
            name STRING COMMENT '专业名称',
            discipline_type STRING COMMENT '所属学科大类(枚举表中ZYDL人文社科类,理工农医类其他',
            discipline STRING COMMENT '所属学科',
            educational_system STRING COMMENT '学制：2年制，3年制，5年制',
                type STRING COMMENT '专业类型：1专科,2本科',
            create_time STRING COMMENT '专业创建时间:格式yyyyMM',
            academy_code STRING COMMENT '院系代码',
            academy_name STRING COMMENT '院系名称',
            rank INT COMMENT '专业排名',
            total_credits DOUBLE COMMENT '总学分',
            total_class_hours DOUBLE COMMENT '总学时',
            construction_basic STRING COMMENT '建设基础',
            basic_type STRING COMMENT '建设基础类型(枚举表:JCLX GJSFZY国家示范专业,GGZY骨干专业,YLZY一流专业,ZDZY重点专业,GGSDZY专业综合改革试点专业专业)',
            construction_goal STRING COMMENT '建设目标',
            goal_type STRING COMMENT '建设目标类型(枚举表:ZYJSMB  GJJTS国家级特色专业,SJTS 省级特色专业,XYJTS 学院级特色专业,GJJZD 国家级重点专业,SJZD 省级重点专业,XYJZD 学院级重点专业)',
            semester_year STRING COMMENT '学期,数据版本'
      )COMMENT '专业基础信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--专业基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}
#学科大类:
#理工农医类 LGNY
#人文社科类 RWSK
#其他类 QT
#------------
#建设基础类型:
#省级专业综合改革专业 GGSDZY
#省级重点专业 ZDZY
#骨干专业 GGZY
function import_table(){
    hive -e "
        INSERT INTO TABLE ${HIVE_DB}.${HIVE_TABLE}
        select distinct
        a.ZYDM as code,
        a.ZYMC as name,
        case
          when a.ZYFL='医药卫生大类' then 'LGNY'
          when a.ZYFL='文化艺术大类' then 'RWSK' else 'QT' end  discipline_type,
        a.ZYFL as discipline,
        '3年制' as educational_system,
        '1' as type,
        a.ZYSZSJ as create_time,
        a.XBH as academy_code,
        a.XMC as academy_name,
        c.rank as rank,
        b.xf as total_credits,
        b.xs as total_class_hours,
        a.JSJC as construction_basic,
         case
         when trim(a.JSJC)='省级专业综合改革专业' then 'SJTSZY'
         when trim(a.JSJC)='省级重点专业' then 'SJZDZY'
         when trim(a.JSJC)='骨干专业' then 'XJZDZY' end  as basic_type,
         a.JSMB as construction_goal,
         case
         when a.JSMB='省级专业综合改革专业' then 'SJTSZY'
         when a.JSMB='省级重点专业' then 'SJZDZY'
         when a.JSMB='骨干专业' then 'XJZDZY' end  goal_type,
         '${SEMESTER_YEAR}' as  semester_year
        from (
            select * from (
                select ROW_NUMBER() OVER(PARTITION BY zydm ORDER BY JSJC desc)  row_num,*
                from raw.zgy_T_ZG_ZYXX
            ) zy
            where zy.row_num=1
        ) a left join
        (
            select KKZYDM,sum(XF) as xf,sum(ZTXS) as xs,substr(XKKH,2,9) xn from raw.sw_T_ZG_KCXXB
            group by KKZYDM,substr(XKKH,2,9)
        )b on a.ZYDM=b.KKZYDM and b.xn='${SEMESTER_YEAR}'
        left join
        (
             select  aa.zydm,aa.xn,
                ROW_NUMBER() OVER(PARTITION BY aa.xn ORDER BY aa.cj desc) rank
            from (
                select b.ZYDM,a.XN,sum(a.CJ) as cj
                from
                raw.sw_T_ZG_XSCJXX a left join raw.sw_t_bzks b
                on a.XH=b.XH
                group by b.ZYDM,a.XN
            ) aa
        ) c on a.ZYDM=c.ZYDM and c.xn='${SEMESTER_YEAR}'
        where cast(substring(ZYSZSJ,1,4) as int)<=${NOW_YEAR}
    "
    fn_log "导入数据--专业基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,discipline_type,discipline,educational_system,type,create_time,academy_code,academy_name,rank,total_credits,total_class_hours,construction_basic,basic_type,construction_goal,goal_type,semester_year"

    fn_log "导出数据--专业基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}

function getYearData(){
    vDate=`date +%Y`
    years=5
    for((i=1;i<=years;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      SEMESTER_YEAR=${PRE_YEAR}"-"${NOW_YEAR}
      import_table
    done
}

init_exit
create_table
getYearData
export_table
finish
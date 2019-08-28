#!/bin/sh
###################################################
###   基础表:      学院基本信息表
###   维护人:      ZhangWeiCe
###   数据源:

###  导入方式:      全量导入
###  运行命令:      sh college_basic_info.sh &
###  结果目标:      model.college_basic_info
###################################################

cd `dirname $0`
source ../../config.sh
exec_dir college_basic_info

HIVE_DB=model
HIVE_TABLE=college_basic_info
TARGET_TABLE=college_basic_info

PRE_YEAR=`date +%Y`
DIRNAME=${PWD##*/}
SEMESTER_YEAR=${PRE_YEAR}"-"$((${PRE_YEAR} + 1))

function create_table(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
        hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
        hive -e "CREATE TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
                                        synopsis   STRING     COMMENT '学院简介',
                                        area_covered   STRING     COMMENT '占地面积（亩）',
                                        architecture_acreage   STRING     COMMENT '建筑面积（平米）',
                                        paper_book   STRING     COMMENT '纸质图书数量',
                                        digital_book   STRING     COMMENT '电子资源数量',
                                        assets_total   STRING     COMMENT '学校总资产（万元）',
                                        dormitory_acreage   STRING     COMMENT '宿舍总面积',
                                        practice_acreage   STRING     COMMENT '实践场所总面积',
                                        administrative_acreage   STRING     COMMENT '行政用房总面积',
                                        practice_seat   STRING     COMMENT '实践教学工位总数',
                                        pc_num   STRING     COMMENT '教学用计算机总台数',
                                        multimedia_room_count   STRING     COMMENT '多媒体教室总数',
                                        multimedia_seat_count   STRING     COMMENT '多媒体教室座位总数',
                                        scientific_instrument_total   STRING     COMMENT '教学科学仪器设备总值（元）',
                                        semester_year   STRING     COMMENT '学年',
                                        province   STRING     COMMENT '省份行政区域代码'        )COMMENT  '学院基本信息表'
LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

        fn_log "创建表--学院基本信息表: ${HIVE_DB}.${HIVE_TABLE}"
}


function create_book_tmp(){
        hadoop fs -rm -r ${BASE_HIVE_DIR}/tmp/book_tmp || :
        hive -e "DROP TABLE IF EXISTS tmp.book_tmp;"
        hive -e "CREATE TABLE IF NOT EXISTS tmp.book_tmp(
                                        paper_book   STRING     COMMENT '纸质图书数量',
                                        digital_book   STRING     COMMENT '电子资源数量')COMMENT  '学院图书信息临时表'
                                        PARTITIONED BY(semester_year STRING COMMENT '学年')
        LOCATION '${BASE_HIVE_DIR}/tmp/book_tmp'"

        fn_log "创建表--学院图书信息临时表: tmp.book_tmp"
}

function import_book_tmp_table(){
     hive -e" INSERT OVERWRITE TABLE tmp.book_tmp PARTITION(semester_year = '${semester}')
            select
                sum(ZKC) paper_book,
                0 digital_book
            FROM raw.zgy_t_zg_tszc
            where cast(substr(RKRQ,1,4) as int)<='${NOW_YEAR}'
     "
    fn_log "导入数据--学院图书信息临时表:tmp.book_tmp"
}

#multimedia_room_count学校原始表T_ZG_DMTJSZWXX多媒体教室总数没有数据
#digital_book学校原始表T_ZG_TSZC中电子图书学校没有图书类型支持
function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
            select '陕西能源职业技术学院，是由国家级重点中专陕西煤炭工业学校、陕西煤矿职工医科大学、省部级重点中专西安煤炭卫生学校、陕西煤炭职工大学合并组建的一所综合性公办普通高等学校。' synopsis,
            nvl(b.XXZDMJPM,0) area_covered,
            nvl(b.XXJZDMJ,0) architecture_acreage,
            CAST(book.paper_book as int) paper_book,
            CAST(book.digital_book as int) digital_book,
            a.zzc assets_total,
            b.XSMJ dormitory_acreage,
            b.SJCSMJ practice_acreage,
            b.JXHZYFMJ administrative_acreage,
            c.XNSJJXGWS practice_seat,
            c.JXJSJS pc_num,
            0 multimedia_room_count,
            c.DMTJSZWS multimedia_seat_count,
            c.JXKYYQSBJZ scientific_instrument_total,
            book.semester_year semester_year,
            '' province
        from tmp.book_tmp book left join
            (select xxzcxx.xn xn,round(xxzcxx.gdzczz+xxzcxx.jxkyyqsbzz+xxzcxx.qtzc,2) zzc,
                         xxzcxx.gdzczz gdzczz,xxzcxx.jxkyyqsbzz jxkyyqsbzz,xxzcxx.qtzc qtzc
            from
            (
            select row_number() over(partition by xn order by xq desc) as rownum , *
            from raw.zgy_t_zg_xxzcxx
            ) as xxzcxx
            where xxzcxx.rownum = 1) a on book.semester_year=a.xn
            left join
            (select xxjxhzyfxx.xn xn ,round(nvl(xxjxhzyfxx.XXZDMJ,0)/666.667,2) XXZDMJPM,
            xxjxhzyfxx.XXJZDMJ XXJZDMJ,xxjxhzyfxx.XSMJ XSMJ,xxjxhzyfxx.SJCSMJ SJCSMJ,xxjxhzyfxx.JXHZYFMJ JXHZYFMJ
            from
            (
            select row_number() over(partition by xn order by xq desc) as rownum , *
            from raw.zgy_t_zg_xxjxhzyfxx
            ) as xxjxhzyfxx
            where xxjxhzyfxx.rownum = 1
            ) b on book.semester_year=b.xn
            left join
            (select dmtjszwxx.xn xn ,dmtjszwxx.XNSJJXGWS XNSJJXGWS,dmtjszwxx.JXJSJS JXJSJS,dmtjszwxx.DMTJSZWS DMTJSZWS,dmtjszwxx.JXKYYQSBJZ JXKYYQSBJZ
            from
            (
            select row_number() over(partition by xn order by xq desc) as rownum , *
            from raw.zgy_t_zg_dmtjszwxx
            ) as dmtjszwxx
            where dmtjszwxx.rownum = 1
            ) c on book.semester_year=c.xn

        "
    fn_log "导入数据--学院基本信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}  \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N'  \
    --columns "synopsis,area_covered,architecture_acreage,paper_book,digital_book,assets_total,dormitory_acreage,practice_acreage,administrative_acreage,practice_seat,pc_num,multimedia_room_count,multimedia_seat_count,scientific_instrument_total,semester_year,province"

    fn_log "导出数据--学院基本信息表: ${HIVE_DB}.${TARGET_TABLE}"

}

function getYearData(){
    vDate=`date +%Y`
    years=5
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
     import_book_tmp_table
    done
}


init_exit
create_table
create_book_tmp
getYearData
import_table
export_table
finish
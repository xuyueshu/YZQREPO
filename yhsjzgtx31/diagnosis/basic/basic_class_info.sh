#!/bin/sh
#################################################
###  基础表:       班级基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_class_info.sh. &
###  结果目标:      model.basic_class_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_class_info

HIVE_DB=model
HIVE_TABLE=basic_class_info
TARGET_TABLE=basic_class_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "
	    CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            code STRING COMMENT '班级代码',
            name STRING COMMENT '班级名称',
            grade STRING COMMENT '入学年级',
            status STRING COMMENT '状态，1：在校、2：已毕业',
            major_code STRING COMMENT '专业代码',
            major_name STRING COMMENT '专业名称',
            academy_code STRING COMMENT '院系代码',
            academy_name STRING COMMENT '院系名称',
            student_num INT COMMENT '学生数量',
            honorary_title_num INT COMMENT '荣誉称号数量'
        )
        COMMENT '班级基础信息表'
        LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
    "

    fn_log "创建表--班级基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}

#T_BZKS_BJAP	班级信息
#T_ZG_ZYXX	专业信息
#t_bzks     本专科生信息
# T_ZG_XG_XSPJJG 学生获奖

function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
          SELECT
                         a.code,
                         a.name,
                         a.grade,
                         a.status,
                         a.major_code,
                         a.major_name,
                         a.academy_code,
                         a.academy_name,
                         b.stunum as student_num,
                         c.num as honorary_title_num
                         from
                       (
                        SELECT
                        bjap.BH AS code,
                        bjap.BJMC as name,
                        xs.XZNJ as grade,
                        xs.SFZX as  status,
                        zyxx.ZYDM as major_code,
                        zyxx.ZYMC as major_name,
                        zyxx.XBH as academy_code,
                        zyxx.XMC as academy_name
                        FROM
                        raw.te_t_bzks_bjap bjap left join
                        raw.sw_t_bzks xs ON bjap.bh=xs.bh
                        left join raw.zgy_T_ZG_ZYXX zyxx ON xs.zydm  = zyxx.zydm
                        where xs.xzdm=3
                        group by bjap.BH, bjap.BJMC,xs.XZNJ,
                        xs.SFZX,zyxx.ZYDM,zyxx.ZYMC,
                        zyxx.XBH,zyxx.XMC
                        ) a
                        left join
                        (select XZNJ, bh,count(xh) as stunum from raw.sw_t_bzks group by XZNJ, bh)b
                        on a.grade=b.XZNJ and a.code=b.bh
                        left join
                        (select bz.XZNJ,bz.bh,count(zg.xh) as num from  raw.sw_t_bzks bz
                         left join raw.sw_T_ZG_XG_XSPJJG zg
                         on bz.XH=zg.XH  group by bz.XZNJ, bz.bh ) c
                         on a.grade=c.XZNJ and a.code=c.bh

    "
    fn_log "导入数据--班级基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,grade,status,major_code,major_name,academy_code,academy_name,student_num,honorary_title_num"

    fn_log "导出数据--班级基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}


init_exit
create_table
import_table
export_table
finish
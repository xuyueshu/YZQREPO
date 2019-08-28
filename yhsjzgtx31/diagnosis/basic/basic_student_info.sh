#!/bin/sh
#################################################
###  基础表:       学生基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_student_info.sh. &
###  结果目标:      model.basic_student_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_student_info

HIVE_DB=model
HIVE_TABLE=basic_student_info
TARGET_TABLE=basic_student_info

function create_table(){

    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :

	hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"

	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
            code STRING  COMMENT '学号',
          name STRING  COMMENT '姓名',
          sex STRING  COMMENT '性别:1男 2女 0其他',
          grade STRING  COMMENT '入学年级',
          degree STRING  COMMENT '培养层次：1专科，2本科，3硕士，4博士',
          educational_system STRING  COMMENT '学制',
          political_status STRING  COMMENT '政治面貌:01中共党员,02中共预备党员,03共青团员,04民革委员,13群众',
          phone STRING  COMMENT '手机号',
          email STRING  COMMENT '邮箱',
          qq_number STRING  COMMENT 'QQ号',
          identity_card STRING  COMMENT '身份证号',
          native_place STRING  COMMENT '籍贯',
          province STRING  COMMENT '来源省,代码',
          city STRING  COMMENT '来源地市,代码',
          county STRING  COMMENT '来源区县,代码',
          middle_school STRING  COMMENT '中学',
          zip_code STRING  COMMENT '家庭邮编',
          home_addr STRING  COMMENT '家庭地址',
          ethnic STRING  COMMENT '民族',
          birth_date STRING  COMMENT '生日',
          enrolment_date STRING  COMMENT '入学日期',
          graduation_date STRING  COMMENT '毕业日期',
          dorm_building_code STRING  COMMENT '宿舍楼号',
          dorm_building_name STRING  COMMENT '宿舍楼名称',
          dorm_room_code STRING  COMMENT '宿舍房间号',
          dorm_room_name STRING  COMMENT '宿舍房间名称',
          home_phone STRING  COMMENT '手机号',
          father_name STRING  COMMENT '父亲姓名',
          mother_name STRING  COMMENT '母亲姓名',
          father_phone STRING  COMMENT '父亲手机号',
          mother_phone STRING  COMMENT '母亲手机号',
          academy_code STRING  COMMENT '学院编号',
          academy_name STRING  COMMENT '学院名称',
          major_code STRING  COMMENT '专业编号',
          major_name STRING  COMMENT '专业名称',
          class_code STRING  COMMENT '班级编号',
          class_name STRING  COMMENT '班级名称',
          status STRING  COMMENT '学籍状态: 1 正常  2 已毕业  100 其他',
          remark STRING  COMMENT '备注',
          in_school STRING  COMMENT '是否在校:1在校,0不在校',
          origin_of_student STRING COMMENT '生源地',
          class_position STRING COMMENT '班级职务',
          students_type STRING COMMENT '生源类型',
          family_conditions STRING COMMENT '家庭经济情况',
          is_only_child STRING COMMENT '是否是独生子女 1是 2否',
          is_martyr STRING COMMENT '是否是烈士 1是 2否',
          is_orphan STRING COMMENT '是否是孤儿 1是 2否',
          is_martyr_children STRING COMMENT '是否是烈士或优抚子女 1是 2否'
      )COMMENT '学生基础信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'
   "
    fn_log "创建表--学生基础信息表 :${HIVE_DB}.${HIVE_TABLE}"
}

#学生基本信息表里面字段缺太多,用考生的数据补充,还是会有很多空的基础信息
function import_table(){
    hive -e "
        INSERT OVERWRITE TABLE ${HIVE_DB}.${HIVE_TABLE}
      select
		 a.xh as code,
         a.xm as name,
         a.xbdm as sex,
         case when g.njdm is null then concat('20',substr(a.xh,1,2)) else g.NJDM end as grade,
         cast(case when a.xzdm='3' or a.xzdm='2' then 1 end as int) as degree,
         case when a.xzdm is null then 5 else cast(a.xzdm as int) end as educational_system,
         case when a.zzmmdm is null  then 13 else  a.zzmmdm end as political_status,
         g.dh as phone,
         ' ' as email,
         g.qq as qq_number,
         a.sfzjh as identity_card,
         g.SYDMC as native_place,
         nvl(h.code,'') as province,
         substr(g.JTDZ,4,3) as city,
         substr(g.JTDZ,7,3) as county,
         g.zxmc as middle_school,
         g.YJDZ as zip_code,
         g.jtdz as home_addr,
         a.mzdm as ethnic,
         COALESCE(g.csny,a.csrq) as birth_date,
         COALESCE(g.rxsj,(case when a.rxrq is null and a.rxrq='' then a.xznj else a.rxrq end)) as enrolment_date,
         ' ' as graduation_date,
         ' ' as dorm_building_code,
         ' ' as dorm_building_name,
         ' ' as dorm_room_code,
         ' ' as dorm_room_name,
         g.dh as home_phone,
         g.fqxm as father_name,
         ' ' as mother_name,
         g.fqdh as father_phone,
         ' '  mother_phone,
         a.dwdm as academy_code,
         e.dwmc as academy_name,
         substr(a.zydm,1,6) as major_code,
         d.zymc as major_name,
         a.bh as class_code,
         f.bjmc as class_name,
         cast(case when a.sfzx='0' then '2' when a.sfzx='1' then 1 else 100 end as int) as status,
         ' ' as remark,
         cast(a.sfzx as int) in_school,
         a.syddm as origin_of_student,
         '' as class_position,
         '' as students_type,
         '' as family_conditions,
        '' as  is_only_child,
        ''   is_martyr,
         '' is_orphan,
         '' is_martyr_children
		  FROM (select * from raw.sw_t_bzks a where a.xznj in ('2016','2017','2018') and a.xh not in (select xh from raw.sw_t_bzks where xznj='2016' and zydm='1701')) a
                left join raw.sunmnet_areazone b on substr(a.sfzjh,1,6)=b.code
                left join (select zydm,zymc from raw.zgy_t_zg_zyxx group by zydm,zymc) d on a.zydm=substr(d.zydm,1,6)
                left join raw.pm_t_xx_dw e on a.dwdm=e.dwdm
                left join raw.te_t_bzks_bjap f on a.bh=f.bh
                left join (select a.* from (select *,row_number() OVER (PARTITION BY xh ORDER BY xn desc) sort
                    from raw.rs_t_zg_ksxx where sfbd='是') a where sort=1) g on a.xh=g.xh
                left join app.basic_area_info h on h.parent_id=0 and substring(a.syddm,1,2)=substring(h.name,1,2)

    "
    fn_log "导入数据--学生基础信息表:${HIVE_DB}.${HIVE_TABLE}"
}

function export_table(){

    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"

    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns "code,name,sex,grade,degree,educational_system,political_status,phone,email,qq_number,identity_card,
        native_place,province,city,county,middle_school,zip_code,home_addr,ethnic,birth_date,enrolment_date,
        graduation_date,dorm_building_code,dorm_building_name,dorm_room_code,dorm_room_name,home_phone,
        father_name,mother_name,father_phone,mother_phone,academy_code,academy_name,major_code,
        major_name,class_code,class_name,status,remark,in_school,origin_of_student,class_position,students_type,
        family_conditions,is_only_child,is_martyr,is_orphan,is_martyr_children"
    fn_log "导出数据--学生基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}

init_exit
create_table
import_table
export_table
finish
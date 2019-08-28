#!/bin/sh
#################################################
###  基础表:       教师基础信息表
###  维护人:       师立朋
###  数据源:

###  导入方式:      全量导入
###  运行命令:      sh basic_teacher_info.sh [&]
###  结果目标:      model.basic_teacher_info
#################################################
cd `dirname $0`
source ../../config.sh
exec_dir basic_teacher_info

HIVE_DB=model
HIVE_TABLE=basic_teacher_info
TARGET_TABLE=basic_teacher_info

function create_table() {
    hadoop fs -rm -r ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} || :
    hive -e "DROP TABLE IF EXISTS ${HIVE_DB}.${HIVE_TABLE};"
    hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_DB}.${HIVE_TABLE}(
        code  STRING COMMENT '教师编号',
        name  STRING COMMENT '教师姓名',
        sex  STRING COMMENT '性别:1男 2女 0其他',
        identity_card  STRING COMMENT'身份证号 ',
        birthdate STRING COMMENT'出生日期:yyyyMMdd',
        politics_status  STRING COMMENT'政治面貌',
        ethnic  STRING COMMENT'民族',
        native_place  STRING COMMENT'籍贯',
        education  STRING COMMENT'学历:专科及以下,专科,本科,硕士研究生,博士研究生 ',
        degree  STRING COMMENT'学位:其他,学士，硕士，博士',
        first_dept_name  STRING COMMENT'一级部门名称',
        first_dept_code  STRING COMMENT'一级部门编号',
        second_dept_name  STRING COMMENT'二级部门名称',
        second_dept_code  STRING COMMENT'二级部门编号',
        professional_title  STRING COMMENT'职称,例如：教授',
        professional_title_level  STRING COMMENT'职称等级 例如 ：正高',
        graduate_school  STRING COMMENT'毕业院校',
        graduate_major  STRING COMMENT'毕业专业',
        graduate_date  STRING COMMENT'毕业时间:yyyyMMdd',
        hire_date  STRING COMMENT'入职时间:yyyyMMdd',
        phone  STRING COMMENT'联系电话',
        is_double_professionally  STRING COMMENT'是否为双师素质教师:0否,1是',
        is_core_teacher  STRING COMMENT'是否为骨干教师:0否,1是',
        is_major_leader STRING COMMENT' 是否为专业带头人:0否,1是',
        is_college_certificate STRING COMMENT'是否具备高校教师资格证:0否,1是',
        is_job_certificate STRING COMMENT'是否具备职业（执业）资格证:0否,1是',
        is_quit STRING COMMENT'是否离职退休:2否,1是',
        position STRING COMMENT'岗位名称',
        position_code STRING COMMENT'岗位编码',
        semester_year STRING COMMENT'学期,数据版本',
        major_code STRING COMMENT'专业代码',
        major_name STRING COMMENT'专业名称',
        academy_code STRING COMMENT'院系代码',
        academy_name STRING COMMENT'院系名称',
        is_famous_teacher STRING COMMENT'是否为教学名师:0否,1是',
        is_major_in_charge STRING COMMENT'是否为专业负责人:0否,1是',
        is_prominent_teacher INT COMMENT'是否是优秀教师:0否,1是',
        estimated_retirement_date STRING COMMENT'预计退休时间',
        staffing_type STRING COMMENT'人员编制类型,例如:事业编,非事业编',
        teacher_type STRING COMMENT'教师类型,例如:校内专任教师,校内兼职教师',
        age INT COMMENT'年龄',
        is_high_level_talents STRING COMMENT'是否高层次人才，1为是，0或空位否',
        is_poverty_alleviation STRING COMMENT'是否扶贫教师，1为是，0或空位否',
        job STRING COMMENT'职务：如教导处主任',
        address STRING COMMENT'家庭住址'
    ) COMMENT '教师基础信息表'
    LOCATION '${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE}'"

    fn_log "创建表--教师基础信息表：${HIVE_DB}.${HIVE_TABLE}"
}

#创建临时表 - 组织机构信息表
# department_code '部门代码',
# department_name  '部门名称',
# department_type  '部门类型代码 1:教学单位 2：非教学单位',
# parents_code  '上级代码',
# degree  '层级 如一级部门，二级部门',
# create_time '创建时间'"
function create_pm_org_department_info(){
    hive -e "DROP TABLE IF EXISTS tmp.pm_org_department_info;"
    hive -e " create table tmp.pm_org_department_info as
                    select
                      a.dwdm as department_code,
                      a.dwmc as department_name,
                      '12510' parent_code,
                      '陕西能源职业技术学院'   parent_name,
                      '1' as degree
                    FROM
                      raw.pm_t_xx_dw a
                    WHERE
                      length(a.dwdm)= 4
                    UNION ALL
                    select
                      a.dwdm as department_code,
                      a.dwmc as department_name,
                      b.dwdm parent_code,
                      b.dwmc   parent_name,
                      '2' as degree
                    FROM
                      raw.pm_t_xx_dw a
                      left join raw.pm_t_xx_dw b on substring(a.dwdm,1,4)=b.dwdm
                    WHERE length(b.dwdm)= 4
                    AND
                      length(a.dwdm)=7
                "
}

#创建部门关系临时表
# first_dept_name  STRING  COMMENT '一级部门名称',
# second_dept_name STRING COMMENT '二级部门名称',
# first_dept_code STRING COMMENT '一级部门编号',
# second_dept_code STRING COMMENT '二级部门编号',
function create_teacher_department_ralation_info() {
hive -e "DROP TABLE IF EXISTS tmp.teacher_department_ralation_info;"
hive -e " create table tmp.teacher_department_ralation_info as
select
                      a.department_name as first_dept_name,
                      b.department_name as second_dept_name,
                      a.department_code as first_dept_code,
                      b.department_code as second_dept_code,
                      substr(a.create_time, 1, 14) as create_time
                    from
                      tmp.pm_org_department_info a,
                      (
                        select
                          b.department_code,
                          b.department_name,
                          b.parents_code
                        from
                          tmp.pm_org_department_info b
                        where
                          b.degree = '2'
                      ) b
                    where
                      a.department_code = b.parents_code

"

}

#//学历  YJS 研究生（博士研究生、硕士研究生）、BK 本科生、DZ 大专、ZZ 中专、GZ 高中 QT 其它
#	YJS("YJS","研究生（博士研究生、硕士研究生"),
#	BK("BK","本科生"),
#	DZ("DZ","大专"),
#	ZZ("ZZ","中专"),
#	GZ("GZ","高中"),
#	QT("QT","其它");
function import_data() {
    hive -e "
        INSERT into TABLE ${HIVE_DB}.${HIVE_TABLE}
        select
			a.ZGH as code,
			a.XM as name,
			cast(case when a.XBDM='1' then 1 when a.XBDM='2' then 2 else 0 end as int) as sex,
			a.SFZJH as identity_card,
			a.CSNY as birthdate,
			a.ZZMMDM as	politics_status,
			a.MZ as	ethnic,
			a.JG as	native_place,
			trim(case when a.ZGXLDM = '14' or a.zgxldm ='15' or a.zgxldm ='16' then '硕士研究生'
                  when a.zgxldm='21' or a.zgxldm= '22' or a.zgxldm ='23' then '本科'
                  when a.zgxldm='31' or a.zgxldm='32' or a.zgxldm ='33' then '专科'
                  when a.zgxldm='11' or a.zgxldm='12' or a.zgxldm ='13' then '博士研究生'
                  when cast(a.zgxldm as int)>=41 then '中专'
                   else '专科'
                   end
                   ) as education,
               trim(case when a.ZGXLDM = '14' or a.zgxldm ='15' or a.zgxldm ='16' then '硕士'
                  when a.zgxldm='21' or a.zgxldm= '22' or a.zgxldm ='23' then '学士'
                  when a.zgxldm='31' or a.zgxldm='32' or a.zgxldm ='33' then ' '
                  when a.zgxldm='11' or a.zgxldm='12' or a.zgxldm ='13' then '博士'
                   else ' '
                   end
                   )  as degree,
			trim(c.department_name) as first_dept_name,
            trim(c.department_code) as first_dept_code,
            trim(dep.department_name) as second_dept_name,
            trim(dep.department_code) as second_dept_code,
			trim(d.ZYJSZW) as professional_title,
			case when trim(d.ZYJSZWJB) like '%正高%' then '正高'
			     when trim(d.ZYJSZWJB) like '%副高%' then '副高'
			     when trim(d.ZYJSZWJB) like '%助理%' then '中级'
			     when trim(d.ZYJSZWJB) like '%初%' then '初级' else '中级'  end as professional_title_level,
			a.BYXX as graduate_school,
			' ' as	graduate_major,
			concat(a.BYRQ, '-', '01') as graduate_date,
			concat(a.LXRQ, '-', '01') as hire_date,
			null as	phone,
            cast(case when trim(a.sfssszjs)='是' then 1
                   when trim(a.sfssszjs)='否' then 0
                  else 0 end as int) as is_double_professionally ,
			cast(case when trim(a.sfggjs) ='是' then 1
                  when trim(a.sfggjs) ='否' then 0 else 0
                  end as int) as is_core_teacher,
			cast(case when trim(a.sfzydtr)='是' then 1
                  when trim(a.sfzydtr)='否' then 0
                   else 0 end as int) as is_major_leader,
			cast( case when a.JSZGZH is not null then 1 else 0 end as int) as is_college_certificate,
			cast(case when a.GRJSDJDM is not null then 1 else 0 end as int) as is_job_certificate,
			cast(if(a.dqztdm='在岗',2,1) as int) as is_quit,
			case when g.ZGH is not null then '辅导员' else '' end  as position,
			nvl(XPGWDM,0)	as	position_code ,
			'${semester}' as	semester_year,
			 e.zydm as major_code,
             e.gszy as major_name,
			a.SZDWDM as academy_code,
			trim(c.department_name) as academy_name,
			cast(0 as int) as	is_famous_teacher,
			cast(case when trim(a.sfzydtr)='是' then 1
                  when trim(a.sfzydtr)='否' then 2
                   else 2 end as int) as is_major_in_charge,
			cast(0 as int) as	is_prominent_teacher ,
			case when a.dqztdm = '不在岗' then cast(
                    substr(a.CJGZRQ, 1, 4)+ a.GL as int
                  ) else '2099' end as estimated_retirement_date ,
			'正式事业编' as staffing_type,

			case when trim(a.jslx)='校内兼职教师' then '校内兼课教师'
			     when trim(a.jslx)='辅导员' then '校内专任教师'
			    else IF(trim(a.jslx) is null,'校内专任教师',trim(a.jslx))  end as teacher_type ,
			cast(year(from_unixtime(unix_timestamp())) as int)-cast(substring(CSNY,1,4) as int)   as age,
			cast(0 as int)  as	is_high_level_talents,
			cast(0 as int)  as	is_poverty_alleviation,
			trim(a.BZLBDM) as job ,
			null as	address
from
                  raw.hr_t_jzg a
                  left join raw.sw_t_zxbz_zzmm b on a.ZZMMDM = b.dm
                  left join tmp.pm_org_department_info c on c.degree=1 and c.department_code = a.SZDWDM
                  left join tmp.pm_org_department_info dep on dep.degree=2 and dep.department_code = a.SZKSDM
                  left join (
                   select * from(
                        select row_number() over(partition by jzgbh order by WID desc) as rownum , *
                        from raw.te_t_jzg_jzcjl
                   ) a where a.rownum=1
                  ) d on d.jzgbh = a.ZGH
                  left join (select max(zydm) as zydm,max(gszy) as gszy,zgh,YBDM,SSYB from raw.pm_t_zg_jszygs group by zgh,YBDM,SSYB) e on e.zgh = a.ZGH
                  left join raw.sw_T_ZG_XG_FDYXXB g on a.ZGH=g.ZGH

                  where substr(a.LXRQ,1,4)<=${NOW_YEAR}
    "
    fn_log "导入数据--教师基础信息表：${HIVE_DB}.${HIVE_TABLE}"
}

function export_data() {
    clear_mysql_data "TRUNCATE TABLE ${TARGET_TABLE};"
    sqoop export --connect ${MYSQL_URL} --username ${MYSQL_USERNAME} --password ${MYSQL_PASSWORD} \
    --table ${TARGET_TABLE} --export-dir  ${BASE_HIVE_DIR}/${HIVE_DB}/${HIVE_TABLE} \
    --input-fields-terminated-by '\0001' --input-null-string '\\N' --input-null-non-string '\\N' \
    --null-string '\\N' --null-non-string '\\N' \
    --columns 'code,name,sex,identity_card,birthdate,politics_status,ethnic,native_place,education,degree,
        first_dept_name,first_dept_code,second_dept_name,second_dept_code,professional_title,professional_title_level,
        graduate_school,graduate_major,graduate_date,hire_date,phone,is_double_professionally,is_core_teacher,is_major_leader,
        is_college_certificate,is_job_certificate,is_quit,position,position_code,semester_year,
        major_code,major_name,academy_code,academy_name,is_famous_teacher,
        is_major_in_charge, is_prominent_teacher,estimated_retirement_date,staffing_type,teacher_type,age,is_high_level_talents,is_poverty_alleviation,job,address'

    fn_log "导出数据--教师基础信息表:${HIVE_DB}.${TARGET_TABLE}"
}
function getYearData(){
    vDate=`date +%Y`
    let vDate+=0;
    for((i=1;i<=5;i++));
    do
      let NOW_YEAR=vDate-i+1
      let PRE_YEAR=vDate-i
      semester=${PRE_YEAR}"-"${NOW_YEAR}
      import_data
    done
}
#create_pm_org_department_info / create_teacher_department_ralation_info 临时表
init_exit
create_table
create_pm_org_department_info
#不需要create_teacher_department_ralation_infof方法
#create_teacher_department_ralation_info
getYearData
export_data
finish



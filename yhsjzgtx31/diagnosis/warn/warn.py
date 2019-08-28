#! /usr/bin/env python
# coding:utf-8
# 预警脚本 根据条件判断是否产生预警,将预警存到对应层面的结果表里面
import time
from itertools import groupby
from operator import itemgetter
from sys import argv
from _mysql_exceptions import ProgrammingError
from base import *


config_file = 'config.conf'
config = ConfigParser.ConfigParser()
config.read(config_file)

db_diagnosis = config.get('diagnosis', 'dbname')
#五纵数据库的连接
conn = Mysql('assurance', config_file)
#五横数据库的连接
conn2 = MysqlHelper('diagnosis',config_file)

result_table = config.get('assurance', 'result_table')
result_record = config.get('assurance', 'result_record')
college_result = config.get('assurance', 'college_result')
major_result = config.get('assurance', 'major_result')
course_result = config.get('assurance', 'course_result')
teacher_result = config.get('assurance', 'teacher_result')
student_result = config.get('assurance', 'student_result')
#实际预警结果只的值
province_code = config.get('province', 'province_code')

#删除预警结果的信息
def delete_result(index_no):
    del_sql = "delete from %s where index_no = '%s'" % (result_table, index_no)
    conn.delete(del_sql)

#删除预警结果当前学年的信息
def delete_target_result(result_table,index_no,semesterYear):
    del_sql = "delete from %s where quality_no = '%s' and semester_year='%s'" % (result_table, index_no,semesterYear)
    conn.delete(del_sql)

#批量插入预警的结果数据
def insert_result(result_list):
    attrs = ['index_no',
             'index_name',
             'menu_no',
             'current_val',
             'standard_val',
             'target_val',
             'warn_val',
             'warn_type',
             'index_lunit',
             'warn_content',
             'index_layer',
             'unit_code',
             'unit_name',
             'unit_code_type',
             'semester_year',
             'semester',
             'create_time']
    conn._insertMany(result_table, attrs, result_list)

#批量插入学院的预警的脚本数据
def insert_college_result(result_list):
    attrs=['semester_year',
           'quality_no',
           'quality_name',
           'is_target',
           'is_standard',
           'create_time']
    conn._insertMany(college_result,attrs,result_list)

#批量插入专业的预警的脚本数据
def insert_major_result(result_list):
    attrs=['semester_year',
           'major_no',
           'major_name',
           'quality_no',
           'quality_name',
           'is_target',
           'is_standard',
           'create_time']
    conn._insertMany(major_result,attrs,result_list)

#批量插入课程的预警的脚本数据
def insert_course_result(result_list):
    attrs=['semester_year',
           'course_code',
           'course_name',
           'quality_no',
           'quality_name',
           'is_target',
           'is_standard',
           'create_time']
    conn._insertMany(course_result,attrs,result_list)

#批量插入教师的预警的脚本数据
def insert_teacher_result(result_list):
    attrs=['semester_year',
           'teacher_no',
           'teacher_name',
           'quality_no',
           'quality_name',
           'is_target',
           'is_standard',
           'create_time']
    conn._insertMany(teacher_result,attrs,result_list)

#批量插入学生的预警的脚本数据
def insert_student_result(result_list):
    attrs=['semester_year',
           'student_no',
           'student_name',
           'quality_no',
           'quality_name',
           'is_target',
           'is_standard',
           'create_time']
    conn._insertMany(student_result,attrs,result_list)

#插入预警的脚本的变化趋势
def insert_warn_record(result_list):
    attrs=['type',
           'name',
           'warn_count',
           'total_count',
           'semester_year',
           'semester']
    conn._insertMany(result_record,attrs,result_list)


#获取当前的学年学期
def get_semester():
    get_index_sql = 'select * from base_school_calendar_info where sort = 1'
    return conn.getOne(get_index_sql)

#获取预警的规则
def get_index_rule(index_no):
    get_rule_sql = "select * from im_quality_warn_rule_info where quality_no = '%s' order by warn_rule_sort" % index_no
    return conn.getAll(get_rule_sql)

#获取所有的单元
def get_all_unit():
    get_unit_sql = "select * from base_dictionaries where dict_status = 'NORMAL'  order by dict_key asc"
    all_unit=conn.getAll(get_unit_sql)
    unit_groupby = groupby(all_unit, itemgetter('dict_key'))
    unit_dict = dict([(k, list(group)) for k, group in unit_groupby])
    return unit_dict

#获取所有的菜单的列表
def get_all_menu():
    sql=" select * from base_function_quality_info where is_warn='YES' order by quality_no asc"
    all_menu=conn.getAll(sql)
    menu_groupby = groupby(all_menu, itemgetter('quality_no'))
    menu_dict = dict([(k, list(group)) for k, group in menu_groupby])
    return menu_dict

#获取预警设置的 标准值 目标值 预警值
def get_param_value(quality_no):
    sql=""" SELECT *
           FROM (
                SELECT quality_no,'' code,'' name,target_val,standard_val,warn_val
                FROM im_college_quality_param_value
                UNION ALL
                SELECT  quality_no,major_no,major_name,target_val,standard_val,warn_val
                FROM  im_major_quality_param_value
                UNION ALL
                SELECT quality_no,group_no,group_name,target_val,standard_val,warn_val
                FROM  im_group_quality_param_value ) a
            WHERE quality_no='%s' """%(quality_no)
    return conn.getAll(sql)


#获取实际的值
def get_value_list(data_no,group_no,type):
    if type == 'COLLEGE' :
        return get_college_value_list(data_no)
    elif type =='MAJOR':
        return get_major_value_list(data_no,group_no)
    else:
        return get_group_value_list(data_no,group_no)

#查询专业,学院的数据项的实际值
def get_college_value_list(data_no):
    sql="""      SELECT  data_no,data_name,'' code,'' name,data_value
                FROM im_quality_data_info
                WHERE  is_new='YES' and  data_no='%s' """%(data_no)
    return conn.getAll(sql)

def get_major_value_list(data_no,code):
    sql="""  SELECT data_no,data_name,major_no  code,major_name name,data_value
            FROM  im_quality_major_data_info
            WHERE  is_new='YES' and data_no='%s' and major_no='%s' """%(data_no,code)
    return conn.getAll(sql)

#获取分组的预警结果
def get_group_value_list(data_no,group_no):
    sql="""  SELECT *
            FROM (
            SELECT data_no,data_name,course_code code,course_name name,data_value
            FROM  im_quality_course_data_info
            WHERE is_new='YES'
            UNION ALL
            SELECT  data_no,data_name,teacher_no code,teacher_name name,data_value
            FROM  im_quality_teacher_data_info
            WHERE is_new='YES'
            UNION ALL
            SELECT data_no,data_name,student_no code,student_name name,data_value
            FROM  im_quality_student_data_info
            WHERE is_new='YES'
            ) a
            WHERE data_no='%s' AND name IN (  
                SELECT DISTINCT name 
                FROM (
                SELECT  group_no,course_code name,course_name name
                FROM base_course_group_detail
                UNION ALL
                SELECT group_no,teacher_no name,teacher_name name
                FROM base_teacher_group_detail
                UNION ALL
                SELECT group_no,student_no name,student_name name
                FROM  base_student_group_detail
                )b   WHERE group_no='%s' )  """ %(data_no,group_no)
    return conn.getAll(sql)


#获取计量的单位
def get_unit(field_key,data_type):
    if data_type == 'NUMER':
        unit_list = unit_dict.get('JLDW')
        for unit in unit_list:
            if unit.get('field_key') == field_key:
                return unit.get('field_value')
    elif data_type == 'ENUM':
        return ''
    else:
        return ''

#菜单质控点列表信息
def memu_index_list(quality_no):
    return menu_dict.get(quality_no)


#进行规则对比
def check_rule(rule, value,para_value):
    compare_value = para_value.get('warn_val')
    compare_way = rule.get('compare_way')
    return eval("%s%s%s" % (value, compare_way, compare_value))


#多次规则的对比
def check_rule_list(rule_list, value,param_value):
    if not rule_list:
        return False
    result_b = ''
    for rule in rule_list:
        rule_relation = (
            ' and ' if (rule.get("rule_relation") == 'AND') else (
                ' or ' if (rule.get("rule_relation") == 'OR') else ''))
        result_b = result_b + rule_relation + str(check_rule(rule, value,param_value))
    print '校验指标预警生效时间结果', result_b
    return eval(result_b)


#查询所有的质控点数据
def get_all_quality_list():
    sql="""  SELECT DISTINCT b.index_layer,b.data_no,b.data_name,b.data_type,a.quality_no,a.quality_name,a.index_lunit,a.dict_key
            FROM  im_quality_data_base_info  b
            INNER JOIN im_quality_info  a
            ON a.data_no=b.data_no
            INNER JOIN base_function_quality_info c
            ON c.quality_no=a.quality_no
            WHERE a.quality_status='NORMAL' AND b.data_status='OPEN' AND is_warn='YES'   """
    return conn.getAll(sql)

#预警标准与目标值 结果的比较
def check_stand_result_rule(compare_way,value,param):
    d=[]
    if eval("%s%s%s" % (value, compare_way, param.get('standard_val'))):
        d.append('NO')
    else:
        d.append("YES")
    if  eval("%s%s%s" % (value, compare_way, param.get('target_val'))):
        d.append("NO")
    else:
        d.append("YES")
    return d

#插入预警的信息
def insert_warn_info(quality):
    type=quality.get("index_layer")   # 层级  学院  学生  专业  课程  教师
    data_type=quality.get("data_type") #数据类型  数值  NUMBER 以及枚举ENUM
    dict_key=get_unit(quality.get("index_lunit"),data_type) # 获取计量单位
    quality_no=quality.get("quality_no")#  质控点编号
    menu_list=menu_dict.get(quality_no)  # 质控点 对应的菜单列表
    print '质控点的层级是',type,data_type,quality.get("data_no")
    delete_result(quality_no)
    print '删除之前的预警的数据'
    param_value_list=get_param_value(quality_no)
    print '获取预警所有的参数 预警值  标准值 目标值 '
    rule_list = get_index_rule(quality_no)  #获取改质控点的比较规则
    result_list = []
    result_college_list = []
    result_major_list = []
    print '获取改预警所有的规则.....'
    for param_value in param_value_list:
        value_list=get_value_list(quality.get("data_no"),param_value.get("code"),type) #质控点对应数据项对应的值
        if not value_list:
            print '获取指标预警结果为空,退出'
            continue
        for value in list(filter(lambda v: check_rule_list(rule_list, v.get('data_value'),param_value), value_list)):
            for menu in menu_list:
                value_d = [
                    quality_no,
                    quality.get('quality_name'),
                    menu.get('menu_no'),
                    value.get('data_value'),
                    param_value.get('standard_val'),
                    param_value.get('target_val'),
                    param_value.get('warn_val'),
                    'YES',
                    dict_key,
                    quality.get('quality_name')+'质控未达标',
                    type,
                    value.get('code'),
                    value.get('name'),
                    type,
                    semester_info.get('semester_year'),
                    semester_info.get('semester'),
                    time.strftime('%Y%m%d%H%M%S', time.localtime())
                ]
                result_list.append(value_d)
        if data_type=='ENUM':
            print '枚举类型，暂不做标准 目标值比较'
            continue
        if type=='COLLEGE':
            for value in value_list:
                d=check_stand_result_rule(rule_list[0].get('compare_way'),value.get('data_value'),param_value)
                #print 'd的数值',d[0],d[1]
                value_d=[
                    semester_info.get('semester_year'),
                    quality.get('quality_no'),
                    quality.get('quality_name'),
                    d[0],
                    d[1],
                    time.strftime('%Y%m%d%H%M%S', time.localtime())
                ]
                result_college_list.append(value_d)
        else:
            for value in value_list:
                d=check_stand_result_rule(rule_list[0].get('compare_way'),value.get('data_value'),param_value)
                value_d=[
                    semester_info.get('semester_year'),
                    value.get('code'),
                    value.get('name'),
                    quality.get('quality_no'),
                    quality.get('quality_name'),
                    d[0],
                    d[1],
                    time.strftime('%Y%m%d%H%M%S', time.localtime())
                ]
                result_major_list.append(value_d)
    #往预警结果 里面插入数据.....
    print '打印输出结果的长度',len(result_list)
    if  len(result_list)>0:
        insert_result(result_list)

    if len(result_college_list)==0 and len(result_major_list)==0:
        print '预警数据为空.....'
        return

    if type=='COLLEGE':
        delete_target_result(college_result,quality.get('quality_no'),semester_info.get('semester_year'))
        insert_college_result(result_college_list)
    elif type =='MAJOR':
        delete_target_result(major_result,quality.get('quality_no'),semester_info.get('semester_year'))
        insert_major_result(result_major_list)
    elif type =='COURSE':
        delete_target_result(course_result,quality.get('quality_no'),semester_info.get('semester_year'))
        insert_course_result(result_major_list)
    elif type =='TEACHER':
        delete_target_result(teacher_result,quality.get('quality_no'),semester_info.get('semester_year'))
        insert_teacher_result(result_major_list)
    elif type =='STUDENT':
        delete_target_result(student_result,quality.get('quality_no'),semester_info.get('semester_year'))
        insert_student_result(result_major_list)


def delte_warn_record_info(semesterYear,semester):
    sql="""delete from sunmnet_warn_result_record  
          where semester_year='%s' and semester='%s' """ %(semesterYear,semester)
    conn.delete(sql)

def get_warn_count(semesterYear,semester):
    sql="SELECT index_layer,COUNT(DISTINCT index_no) num  FROM  sunmnet_index_warn_result where semester_year='%s' and semester='%s' GROUP BY index_layer  "%(semesterYear,semester)
    warn_count=conn.getAll(sql)
    list_keys=[]
    list_values=[]
    for v in warn_count:
        list_keys.append(v.get('index_layer'))
        list_values.append(v.get('num'))
    return dict(zip(list_keys,list_values))

def get_setting_warn_count():
    sql="""  
        SELECT a.index_layer,
        case a.index_layer  
             when 'COLLEGE' then '学院'
             when 'STUDNENT' then '学生'
             when 'TEACHER' then '教师'
             when 'COURSE' then '课程'
             when 'MAJOR' then '专业'
        end name              
        ,COUNT(DISTINCT a.quality_no) num
        FROM  im_quality_data_base_info  b
        INNER JOIN im_quality_info  a
        ON a.data_no=b.data_no
        INNER JOIN base_function_quality_info c
        ON c.quality_no=a.quality_no
        WHERE a.quality_status='NORMAL' AND b.data_status='OPEN' AND is_warn='YES' 
        GROUP BY a.index_layer   """
    return conn.getAll(sql)

def insert_warn_record_info():
    delte_warn_record_info(semester_info.get('semester_year'),semester_info.get('semester'))
    print '删除本学年学期的预警的记录信息  查询设置预警的信息 以及产生预警的总信息'
    #预警趋势的数据
    warn_record_list=[]
    warn_count=get_warn_count(semester_info.get('semester_year'),semester_info.get('semester'))
    set_count=get_setting_warn_count()
    for warn in set_count:
        print '层级',warn.get('index_layer'),warn.get('num'),
        record=[
            warn.get('index_layer'),
            warn.get('name'),
            warn_count.get(warn.get('index_layer'),"0"),
            warn.get('num'),
            semester_info.get('semester_year'),
            semester_info.get('semester')
        ]
        warn_record_list.append(record)
    if len(warn_record_list)>0:
        insert_warn_record(warn_record_list)

if __name__ == '__main__':
    semester_info = get_semester()
    print '当前学年:', semester_info.get('semester_year'), '当前学期:', semester_info.get('semester')
    unit_dict = get_all_unit()
    print '获取字典表.'
    menu_dict=get_all_menu()
    print '获取所有的菜单质控点信息'
    quality_list=get_all_quality_list()
    if not quality_list:
        print '没有质控点信息......'
    print '查询所有的质控点的列表',len(quality_list)
    for quality in quality_list:
       insert_warn_info(quality)

    print '质控点脚本执行完毕.....插入质控点预警总数和设置总数'
    insert_warn_record_info()
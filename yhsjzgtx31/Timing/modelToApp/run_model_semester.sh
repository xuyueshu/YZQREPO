#!/bin/sh
cd `dirname $0`

#运行五横数据college/course/teacher/student/major 每学期一次执行统一执行脚本
#学院model路径 ：/root/etl/SXNYZY/diagnosis/college
#课程model路径 ：/root/etl/SXNYZY/diagnosis/course
#教师model路径 ：/root/etl/SXNYZY/diagnosis/teacher
#学生model路径 ：/root/etl/SXNYZY/diagnosis/student
#专业model路径 ：/root/etl/SXNYZY/diagnosis/major

BASIC="
basic_ecard_consume_record.sh
basic_major_info.sh
basic_semester_info.sh
basic_textbook_info.sh
"
COLLEGEMODEL="
college_exit_record.sh
college_international_cooperation.sh
"
COURSEMODEL="
course_evaluation_teaching_info.sh
course_implement.sh
course_kpi_standard_state.sh
course_resource.sh
course_satisfaction_info.sh
course_supervision_info.sh
course_training_info.sh
"
MAJORMODEL="
major_course_record.sh
major_instructional_resources.sh
major_trainingProject_detailed.sh
"
TEACHERMODEL="
teacher_change_class_info.sh
teacher_course_info.sh
teacher_student_book_lending_record.sh
teacher_workload_information_record.sh
"
STUDENTMODEL="
student_attendance_info.sh
student_excellent.sh
student_grade_test_detailed.sh
student_join_community.sh
student_social_activity.sh
"

#日志路径
function getRunLogPath(){
    datetime=$(date --date "0 days ago" +%Y%m%d)
    if [ ! -d "./logs" ];then
        mkdir ./logs
    fi
    LOG_RUN_PATH=/root/etl/SXNYZY/Timing/logs/$0_${datetime}.log
}


function doconmand(){
    start=$(date +%s)
    #读取文件的每一行
	for comand in ${comands}
	do
		ps -ef|grep $comand|grep -v grep|cut -c 9-15|xargs kill -9
	    sh $comand
	    end=$(date +%s)
		 if [ $? -eq 0 ]; then
	    	echo " $comand succeed>>>  耗时$(( $end - $start ))s " >>  ${LOG_RUN_PATH} 2>&1
		 else
		    echo " $comand failed>>>  耗时$(( $end - $start ))s "  >>  ${LOG_RUN_PATH} 2>&1;
		    echo " ## sh $comand 脚本执行错误，退出命令  exit 1  ##"  >>  ${LOG_RUN_PATH} 2>&1;
		    exit 1;
		 fi

	done
	end=$(date +%s)
	echo " 耗时$(( $end - $start ))s" >>  ${LOG_RUN_PATH} 2>&1
	#删除脚本执行过程中产生的Java文件
	rm -rf *.java
}

#BASIC层面_model
function BASIC() {
   echo "-------BASIC层面--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${BASIC[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;
}
#学院层面_model
function COLLEGEMODEL() {
   echo "-------学院层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${COLLEGEMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;
}
#课程层面_model
function COURSEMODEL() {
   echo "-------课程层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${COURSEMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;
}

#专业层面
function MAJORMODEL() {
   echo "-------专业层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${MAJORMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}
#教师层面
function TEACHERMODEL() {
   echo "-------教师层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${TEACHERMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}
#学生层面
function STUDENTMODEL() {
   echo "-------学生层面_MODEL开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${STUDENTMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}


getRunLogPath
CURRENTPATH_COLLEGE=/root/etl/SXNYZY/diagnosis
comands=()

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/basic/
	BASIC
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/college/
	COLLEGEMODEL
fi
if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/course/
	COURSEMODEL
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/major/
	MAJORMODEL
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/teacher/
	TEACHERMODEL
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/student/
	STUDENTMODEL
fi



echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1


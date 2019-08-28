#!/bin/sh
cd `dirname $0`
#运行自诊报告层面   定时脚本

COURSE="
qu_course_diagnosis_report.sh
qu_course_diagnosis_report_quality.sh
qu_course_diagnosis_report_score.sh
qu_course_diagnosis_report_team.sh
"
MAJOR="
qu_major_diagnosis_report.sh
qu_major_diagnosis_report_quality.sh
qu_major_diagnosis_report_student.sh
"

STUDENT="
qu_student_diagnosis_report.sh
qu_student_diagnosis_report_award.sh
qu_student_diagnosis_report_award_sort.sh
qu_student_diagnosis_report_score.sh
"
TEACHER="
qu_teacher_diagnosis.sh
qu_teacher_diagnosis_course_report.sh
qu_teacher_diagnosis_report_research_service.sh
qu_teacher_diagnosis_report_task.sh
qu_teacher_diagnosis_report_train.sh
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
		end=$(date +%s)
		ps -ef|grep $comand|grep -v grep|cut -c 9-15|xargs kill -9
	    sh $comand
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
#课程层面
function docourse() {
   echo "-------课程层面开始全部执行--------"
   comands=${COURSE[*]}
   doconmand

}
#专业层面
function domajor() {
   echo "-------专业层面开始全部执行--------"
   comands=${MAJOR[*]}
   doconmand

}
#教师层面
function doteacher() {
   echo "-------教师层面开始全部执行--------"
   comands=${TEACHER[*]}
   doconmand

}
#学生层面
function dostudent() {
  echo "-------学生层面开始全部执行--------"
   comands=${STUDENT[*]}
   doconmand

}


getRunLogPath
echo "日志路径:"$LOG_RUN_PATH
currentPath=/root/etl/SXNYZY/SelfDiagnosisReport
echo "脚本路径:"$currentPath
comands=()

if [ $? -eq 0 ]; then
	cd  $currentPath/course
	docourse
fi

if [ $? -eq 0 ]; then
	cd  $currentPath/major
	domajor
fi

if [ $? -eq 0 ]; then
	cd  $currentPath/student
	dostudent
fi

if [ $? -eq 0 ]; then
	cd  $currentPath/teacher
	doteacher
fi


echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1


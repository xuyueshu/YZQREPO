#!/bin/sh
cd `dirname $0`

#运行五横数据college/course/teacher/student/major 每学年一次执行统一执行脚本
#学院app路径 ：/root/etl/SXNYZY/diagnosis/college/app
#课程course路径 ：/root/etl/SXNYZY/diagnosis/course/app
#教师teacher路径 ：/root/etl/SXNYZY/diagnosis/teacher/app
#学生student路径 ：/root/etl/SXNYZY/diagnosis/student/app
#专业major路径 ：/root/etl/SXNYZY/diagnosis/major/app

COLLEGEAPP="
college_assets_student_avg.sh
college_enrolment_method_count.sh
college_party_info.sh
college_scientific_count.sh
college_social_work_count.sh
"
MAJORAPP="
major_abroad_communication_count.sh
major_development_course.sh
major_donation_all_count.sh
major_plan_student.sh
major_scientific_info.sh
major_student_birthplace.sh
major_total_info.sh
"
TEACHERAPP="
teacher_community_info.sh
teacher_high_level_count.sh
teacher_managerial_position_record.sh
"
STUDENTAPP="
student_graduate_employment_count.sh
student_income_record.sh
student_one_card.sh
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
#学院层面_app
function COLLEGEAPP() {
   echo "-------学院层面_app开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${COLLEGEAPP[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;
}

#专业层面_app
function MAJORAPP() {
   echo "-------专业层面_app开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${MAJORAPP[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}
#教师层面_app
function TEACHERAPP() {
   echo "-------教师层面_app开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${TEACHERAPP[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}
#学生层面_app
function STUDENTAPP() {
   echo "-------学生层面_app开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${STUDENTAPP[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}


getRunLogPath
CURRENTPATH_COLLEGE=/root/etl/SXNYZY/diagnosis
comands=()

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/college/app
	COLLEGEAPP
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/major/app
	MAJORAPP
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/teacher/app
	TEACHERAPP
fi

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/student/app
	STUDENTAPP
fi

echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1


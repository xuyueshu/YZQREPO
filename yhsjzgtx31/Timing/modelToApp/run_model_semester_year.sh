#!/bin/sh
cd `dirname $0`

#运行五横数据college/course/teacher/student/major 每学年一次执行统一执行脚本
#学院model路径 ：/root/etl/SXNYZY/diagnosis/college
#课程model路径 ：/root/etl/SXNYZY/diagnosis/course
#教师model路径 ：/root/etl/SXNYZY/diagnosis/teacher
#学生model路径 ：/root/etl/SXNYZY/diagnosis/student
#专业model路径 ：/root/etl/SXNYZY/diagnosis/major

COLLEGEMODEL="
college_admin_team_info.sh
college_basic_info.sh
college_digital_campus.sh
college_quality_info.sh
college_social_influence_count.sh
"
COURSEMODEL="
course_group_course_info.sh
course_group_info.sh
course_group_teacher_info.sh
"

MAJORMODEL="
major_donation_major_count.sh
major_enroll_area_count.sh
major_enroll_student.sh
major_excellent_graduate.sh
major_outSchool_award.sh
major_post_practice_count.sh
major_social_work.sh
major_trainingRoom_detailed.sh
"
TEACHERMODEL="
teacher_awards_info.sh
teacher_growing_assessment_info.sh
teacher_growing_info.sh
teacher_guidance_competition.sh
teacher_guidance_help_record.sh
teacher_project_count.sh
teacher_resource_build_info.sh
teacher_social_work.sh
teacher_teaching_research_info.sh
teacher_teaching_research_personnel_info.sh
teacher_textbook_personnel_info.sh
"
STUDENTMODEL="
student_birthplace_loan_record.sh
student_community_information.sh
student_directed_education.sh
student_graduate_employment_record.sh
student_grant_detailed.sh
student_job_orientation.sh
"
SCIENTIFIC="
scientific_author_patent_info.sh
scientific_award_result_info.sh
scientific_paper_basic_info.sh
scientific_paper_personnel_info.sh
scientific_patent_achievements.sh
scientific_project_basic_info.sh
scientific_project_funds_info.sh
scientific_project_personnel_info.sh
scientific_team_info.sh
scientific_work_basic_info.sh
scientific_work_personnel_info.sh
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
#教师层面_app
function TEACHERMODEL() {
   echo "-------教师层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${TEACHERMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}
#学生层面_app
function STUDENTMODEL() {
   echo "-------学生层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${STUDENTMODEL[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}

function SCIENTIFIC() {
   echo "-------科研层面开始全部执行--------" >>  ${LOG_RUN_PATH} 2>&1;
   comands=${SCIENTIFIC[*]}
   doconmand >>  ${LOG_RUN_PATH} 2>&1;

}

getRunLogPath
CURRENTPATH_COLLEGE=/root/etl/SXNYZY/diagnosis
comands=()

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

if [ $? -eq 0 ]; then
	cd  ${CURRENTPATH_COLLEGE}/scientific/
	SCIENTIFIC
fi

echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1


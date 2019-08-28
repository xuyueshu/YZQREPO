#!/bin/sh
cd `dirname $0`
###########依次执行全部major脚本###########

RUN_SHELL="
major_actual_enrollment.sh
major_age_structure.sh
major_art_award_num.sh
major_average_instrument.sh
major_backbone_teachers.sh
major_begin_class.sh
major_development_course_book_num.sh
major_development_course_num.sh
major_donation_device_price_count.sh
major_double_qualified_teachers.sh
major_employment_rate.sh
major_excellent_online_open_courses.sh
major_first_volunteer_application_rate.sh
major_fulltime_teacher.sh
major_graduation_rate.sh
major_innovate_award_num.sh
major_international_communication.sh
major_internship_accept_rate.sh
major_internship_rate.sh
major_is_innovate_course.sh
major_is_quality_course.sh
major_modern_apprentice.sh
major_number_of_cooperative_enterprises.sh
major_number_of_enrollment_plans.sh
major_number_of_professional_teachers.sh
major_number_of_students_in_school.sh
major_number_of_teachers_awarded.sh
major_number_of_textbooks_selected.sh
major_number_of_training_bases.sh
major_off_campus_training_base.sh
major_order_class.sh
major_other_award_num.sh
major_part_time_teacher.sh
major_portrait_arrivalmoney.sh
major_portrait_scientific_num.sh
major_post_practice_attendance_rate.sh
major_post_practice_newspaper_rate.sh
major_post_practice_newspaper_subrate.sh
major_post_practice_num.sh
major_post_practice_student_score.sh
major_post_practice_weekly_rate.sh
major_post_practice_weekly_subrate.sh
major_professional_leader.sh
major_professional_proportion.sh
major_registration_rate.sh
major_skill_award_num.sh
major_sociology_service_arrivalmoney.sh
major_sociology_service_num.sh
major_student_abroad.sh
major_teacher_abroad.sh
major_teachering_hours.sh
major_teaching_resource_bank.sh
major_test_passing_rate.sh
major_title_structure.sh
major_total_equipment_value.sh
major_training_room.sh
major_transverse_arrivalmoney.sh
major_transverse_scientific.sh
major_workstation.sh
"
function find_mysql_data() {
	mysql -h ${MYSQL_HOST} -u ${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -P${MYSQL_PORT} -N -e "USE ${MYSQL_DB};${1}"
}

function doconmand(){
    start=$(date +%s)
    datetime=$(date --date "0 days ago" +%Y%m%d)
    #读取文件的每一行
	for comand in ${comands}
	do
		end=$(date +%s)
		ps -ef|grep $comand|grep -v grep|cut -c 9-15|xargs kill -9
		source ./$comand
		is_open=`find_mysql_data "select data_status from im_quality_data_base_info where data_no ='${DATA_NO}';" `
		DATA_STATUS=`find_mysql_data "select data_status from assurance.im_quality_data_base_info  where data_name = '${DATA_NAME}';"`
         if [ $is_open == "OPEN" ]
         then
            clear_mysql_data "update assurance.im_quality_data_base_info set script_status = 'YES' where data_no ='${DATA_NO}'"
             create_table >>  ${LOG_RUN_PATH} 2>&1
             import_table >>  ${LOG_RUN_PATH} 2>&1
             export_table >>  ${LOG_RUN_PATH} 2>&1
         elif [ $DATA_STATUS == "OPEN" ]
         then
             clear_mysql_data "update assurance.im_quality_data_base_info set script_status='YES' where data_name = '${DATA_NAME}'"
             create_table >>  ${LOG_RUN_PATH} 2>&1
             import_table >>  ${LOG_RUN_PATH} 2>&1
             export_table >>  ${LOG_RUN_PATH} 2>&1
         else
            echo " $comand 质控点没有开启 " >>  ${LOG_RUN_PATH} 2>&1

         fi
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

function getRunLogPath(){
    datetime=$(date --date "0 days ago" +%Y%m%d)
    if [ ! -d "./logs" ];then
        mkdir ./logs
    fi
    LOG_RUN_PATH=/root/etl/SXNYZY/Timing/logs/$0_${datetime}.log
}



function dorawsh(){
	echo "*******全部college脚本开始执行*********" >>  ${LOG_RUN_PATH} 2>&1
	comands=${RUN_SHELL[*]}
	doconmand
	}

function testmysql(){
	port=`netstat -nlt|grep 3306|wc -l`
	if [ $port -ne 1 ]
	then
	   echo "MySQL is NOT running, exit 1 " >>  ${LOG_RUN_PATH} 2>&1
	   exit 1;
	else
	   echo "MySQL is running" >>  ${LOG_RUN_PATH} 2>&1
	fi
}

getRunLogPath
echo $LOG_RUN_PATH
currentPath=/root/etl/SXNYZY/QualityControlPoint/major
comands=()
echo $currentPath

if [ $? -eq 0 ]; then
	cd  $currentPath
	dorawsh
fi


echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1

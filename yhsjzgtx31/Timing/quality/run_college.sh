#!/bin/sh
cd `dirname $0`
###########依次执行全部college脚本###########
RUN_SHELL="
college_above_the_provincial_level.sh
college_access_bandwidth.sh
college_actual_enrollment.sh
college_actual_reporting_rate.sh
college_amount_to_money.sh
college_apprenticeship_rate.sh
college_area_covered.sh
college_area_structure.sh
college_average_living_quarters_area.sh
college_book_num.sh
college_books_per_student.sh
college_cooperation_and_exchange_project.sh
college_department_set_num.sh
college_developing_the_proportion_of_courses_jointly.sh
college_double_teacher_num.sh
college_double_teacher_num_radio.sh
college_excellent_online_open_course.sh
college_excellent_resources_sharing_course.sh
college_exchange_of_visits.sh
college_full_time_teacher_of_average_course_time.sh
college_gender_ratio_of_official_cadres.sh
college_gender_ratio_of_section_cadres.sh
college_high_level_num.sh
college_in_school_practice_base_num.sh
college_integration_project_of_industry_and_education.sh
college_international_cooperation_and_exchange.sh
college_intra_provincial_source_ratio.sh
college_investment_amount_of_digital_campus.sh
college_item_number.sh
college_leader_num.sh
college_leader_sex_num.sh
college_major_developing_teaching_materials.sh
college_media_coverage.sh
college_new_media_operations.sh
college_number_of_associations.sh
college_number_of_computer_rooms.sh
college_number_of_cooperative_enterprises.sh
college_number_of_databases.sh
college_number_of_enrollment_majors.sh
college_number_of_exogenous_sources_in_province.sh
college_number_of_official_cadres.sh
college_number_of_outstanding_graduates.sh
college_number_of_overseas_students.sh
college_number_of_poor_students.sh
college_number_of_poor_students_radio.sh
college_number_of_scholarship.sh
college_number_of_section_cadres.sh
college_number_of_students_assigned_to_computers.sh
college_on_campus_practical_teaching_for_students.sh
college_order_number_ratio.sh
college_other_leader_num.sh
college_other_leader_sex_num.sh
college_out_school_part_time_class_teacher_num.sh
college_out_school_part_time_class_teacher_num_radio.sh
college_out_school_part_time_teacher_num.sh
college_out_school_part_time_teacher_num_radio.sh
college_out_school_practice_base_num.sh
college_party_activity.sh
college_party_fee_collection_ratio.sh
college_party_honor.sh
college_party_num.sh
college_party_student_develop_num.sh
college_party_student_num_radio.sh
college_party_teacher_develop_num.sh
college_party_teacher_num_radio.sh
college_patent_total.sh
college_per_capita_area.sh
college_planned_enrollment.sh
college_postgraduate_teacher_radio.sh
college_practice_num.sh
college_practice_num_radio.sh
college_practice_place_for_students.sh
college_proportion_of_internship_graduates.sh
college_proportion_of_single_enrollment_types.sh
college_proportion_senior_teachers_full_time_teachers.sh
college_provincial_source_quantity.sh
college_quality_engineering_num.sh
college_quantity_of_business_system_construction.sh
college_quantity_of_evidence_collection.sh
college_rate_of_employment.sh
college_recruit_students.sh
college_research_award.sh
college_research_funding.sh
college_research_project.sh
college_rkdk_bandwidth.sh
college_school_assets.sh
college_school_full_time_num.sh
college_school_full_time_num_radio.sh
college_school_part_time_class_teacher_num.sh
college_school_part_time_class_teacher_num_radio.sh
college_scientific_research_instrument.sh
college_scientific_research_team.sh
college_set_major_num.sh
college_student_graduation_rate.sh
college_student_instructor_ratio.sh
college_student_num.sh
college_student_teacher_ratio.sh
college_student_total_num.sh
college_students_from_other_provinces_ratio.sh
college_students_with_multimedia_classroom_seats.sh
college_supervised_instruction_num.sh
college_teacher_average_age.sh
college_teacher_num.sh
college_teacher_sex_num.sh
college_teaching_administration.sh
college_teaching_check_num.sh
college_teaching_material_and_monograph.sh
college_teaching_material_num.sh
college_the_proportion_of_cooperative_enterprises.sh
college_the_proportion_of_enrollment_types.sh
college_topic_total.sh
college_total_number_of_donated_equipment.sh
college_total_number_of_graduates.sh
college_total_number_of_papers_published.sh
college_total_value_of_donated_equipment.sh
college_training_abroad.sh
college_violation_of_discipline_ratio.sh
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
currentPath=/root/etl/SXNYZY/QualityControlPoint/college
comands=()
echo $currentPath

if [ $? -eq 0 ]; then
	cd  $currentPath
	dorawsh
fi


echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1

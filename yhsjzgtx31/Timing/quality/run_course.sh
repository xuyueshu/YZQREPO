#!/bin/sh
cd `dirname $0`
###########依次执行全部course脚本###########

RUN_SHELL="
course_answering_question.sh
course_audio_quantity.sh
course_average_score.sh
course_class_adjustment_rate.sh
course_excellent_rate.sh
course_job_layout.sh
course_number_of_knowledge_points.sh
course_number_of_online_classes.sh
course_number_of_student_papers.sh
course_number_of_student_problem_sets.sh
course_operation_times.sh
course_output_rate.sh
course_panel_discussion.sh
course_pass_rate.sh
course_peer_test.sh
course_picture_quantity.sh
course_posting_of_forum_courses.sh
course_student_attendance.sh
course_student_evaluation_of_teaching.sh
course_student_questioning.sh
course_substitute_rate.sh
course_supervision_and_evaluation.sh
course_text_quantity.sh
course_training_project.sh
course_video_quantity.sh
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
currentPath=/root/etl/SXNYZY/QualityControlPoint/course
comands=()
echo $currentPath

if [ $? -eq 0 ]; then
	cd  $currentPath
	dorawsh
fi


echo "*********所有脚本执行完毕*********" >>  ${LOG_RUN_PATH} 2>&1

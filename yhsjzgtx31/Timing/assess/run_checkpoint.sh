#!/bin/sh
cd `dirname $0`
#################################################
# 定时脚本
# 绩效考核点
#################################################
function exe_quality_control_point() {
        LOCAL_PATH=/root/etl/SXNYZY/Checkpoint
        cur_dateTime=$(date --date "0 days ago" +%Y%m%d%H%M)
        cd ${LOCAL_PATH}; sh task_completion_rate.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh task_completion_rate 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh task_completion_rate 失败" >> ${LOG_PATH} 2>&1
        fi

        cd ${LOCAL_PATH}; sh mission_early_warning_processing_rate.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh mission_early_warning_processing_rate.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh mission_early_warning_processing_rate.sh 失败" >> ${LOG_PATH} 2>&1
        fi

        cd ${LOCAL_PATH}; sh mission_early_warning_proportion.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh mission_early_warning_proportion.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh mission_early_warning_proportion.sh 失败" >> ${LOG_PATH} 2>&1
        fi

        cd ${LOCAL_PATH}; sh mission_overdue_rate.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh mission_overdue_rate.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh mission_overdue_rate.sh 失败" >> ${LOG_PATH} 2>&1
        fi

        cd ${LOCAL_PATH}; sh number_of_teaching_accidents.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh number_of_teaching_accidents.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh number_of_teaching_accidents.sh 失败" >> ${LOG_PATH} 2>&1
        fi

         cd ${LOCAL_PATH}; sh planning_completion_rate.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh planning_completion_rate.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh planning_completion_rate.sh 失败" >> ${LOG_PATH} 2>&1
        fi

         cd ${LOCAL_PATH}; sh quality_control_point_early_warning.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh quality_control_point_early_warning.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh quality_control_point_early_warning.sh 失败" >> ${LOG_PATH} 2>&1
        fi

            cd ${LOCAL_PATH}; sh student_attendance_rate.sh >> ${LOG_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_attendance_rate.sh 成功" >> ${LOG_PATH} 2>&1
                else echo "${cur_dateTime} sh student_attendance_rate.sh 失败" >> ${LOG_PATH} 2>&1
        fi
}

function getRunLogPath(){
    datetime=$(date --date "0 days ago" +%Y%m%d)
    if [ ! -d "./logs" ];then
        mkdir ./logs
    fi
    LOG_PATH=/root/etl/SXNYZY/Timing/logs/$0_${datetime}.log
}

getRunLogPath
exe_quality_control_point
rm -rf *.java
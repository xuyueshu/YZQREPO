#!/bin/sh
cd `dirname $0`
source ./../config.sh
#################################################
#运行质控点【college/course/student/major/teacher】层面
# run_college.sh
# run_course.sh
# run_major.sh
# run_student.sh
# run_teacher.sh   定时脚本
#################################################

function exe_quality_control_point() {
        LOCAL_PATH=/root/etl/SXNYZY/Timing/
        cur_dateTime=$(date --date "0 days ago" +%Y%m%d%H%M)
        cd ${LOCAL_PATH}; sh run_college.sh >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh run_college.sh 成功" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
                else echo "${cur_dateTime} sh run_college.sh 失败" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
        fi

        cd ${LOCAL_PATH}; sh run_course.sh >> ${LOCAL_PATH}/logs/quality_control_point.log 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh run_course.sh 成功" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
                else echo "${cur_dateTime} sh run_course.sh 失败" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
        fi

        cd ${LOCAL_PATH}; sh run_major.sh >> ${LOCAL_PATH}/logs/quality_control_point.log 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh run_major.sh 成功" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
                else echo "${cur_dateTime} sh run_major.sh 失败" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
        fi

        cd ${LOCAL_PATH}; sh run_student.sh >> ${LOCAL_PATH}/logs/${0}.log 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh run_student.sh 成功" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
                else echo "${cur_dateTime} sh run_student.sh 失败" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
        fi

        cd ${LOCAL_PATH}; sh run_teacher.sh >> ${LOCAL_PATH}/logs/${0}.log 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh run_teacher.sh 成功" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
                else echo "${cur_dateTime} sh run_teacher.sh 失败" >> ${LOG_RUN_PATH}/logs/${0}.log 2>&1
        fi
}

function getRunLogPath(){
    datetime=$(date --date "0 days ago" +%Y%m%d)
    if [ ! -d "./logs" ];then
        mkdir ./logs
    fi
    LOG_RUN_PATH=/root/etl/SXNYZY/Timing/
}

getRunLogPath
exe_quality_control_point
finish
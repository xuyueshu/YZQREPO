#!/bin/sh
cd `dirname $0`
#################################################
#每月一次统一执行脚本
#################################################

function exe_diagnosis_script() {
        LOCAL_PATH=/root/etl/SXNYZY/diagnosis/
        cur_dateTime=$(date --date "0 days ago" +%Y%m%d%H%M)
        cd ${LOCAL_PATH}/student/; sh student_award_info.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_award_info 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_award_info 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_diligent_study_detailed.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_diligent_study_detailed 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_diligent_study_detailed 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_dormitory_sanitation.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_dormitory_sanitation 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_dormitory_sanitation 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_physical_test_record.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_physical_test_record 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_physical_test_record 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
         cd ${LOCAL_PATH}/student/; sh student_psychological_test_record.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_psychological_test_record 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_psychological_test_record 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_papers.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_papers 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_papers 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
         cd ${LOCAL_PATH}/student/; sh student_lecture_info.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_lecture_info 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_lecture_info 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_score_record.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_score_record 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_score_record 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_poor_record.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_poor_record 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_poor_record 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
         cd ${LOCAL_PATH}/student/; sh student_pull_tonight.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_pull_tonight 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_pull_tonight 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/student/; sh student_scholarship_record.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh student_scholarship_record 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh student_scholarship_record 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/party/; sh party_activity_info.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh party_activity_info 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh party_activity_info 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/party/; sh party_fee_info.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh party_fee_info 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh party_fee_info 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
        cd ${LOCAL_PATH}/party/; sh party_honor_info.sh >> ${LOG_RUN_PATH} 2>&1
        if [ $? -eq 0 ]
                then echo "${cur_dateTime} sh party_honor_info 成功" >> ${LOG_RUN_PATH} 2>&1
                else echo "${cur_dateTime} sh party_honor_info 失败" >> ${LOG_RUN_PATH} 2>&1
        fi
}

function getRunLogPath(){
    datetime=$(date --date "0 days ago" +%Y%m%d)
    if [ ! -d "./logs" ];then
        mkdir ./logs
    fi
    LOG_RUN_PATH=/root/etl/SXNYZY/Timing/logs/$0_${datetime}.sh
}

getRunLogPath
exe_diagnosis_script
rm -rf *.java
#!/bin/sh
#######每天一次脚本执行
#学生上网流水表
sh /root/etl/SXNYZY/diagnosis/basic/basic_network_record.sh
#学生违纪明细表
sh /root/etl/SXNYZY/diagnosis/student/student_disciplinary_info.sh
rm -rf *.java



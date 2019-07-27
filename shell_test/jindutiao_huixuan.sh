#!/bin/bash
##显示进度条
while :
do
	for i in {1..20}
	do
		echo -e "\033[3;${i}H*"
		sleep 0.2
	done
	clear
	
	for i in {20..1}
	do
		echo -e "\033[3;${i}H*"
		sleep 0.2
	done
	
	ps auxf|grep $0|grep -v grep|awk '{print $2}'|xargs kill -9
	ps auxf|grep 'jindutiao_huixuan.sh'|grep -v grep|awk '{print $2}'|xargs kill -9
	echo "#######已杀掉该进程########"
done

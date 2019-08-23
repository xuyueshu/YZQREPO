#!/bin/bash
##脚本删除linux系统中自带jdk
while :
do
	file=`rpm -qa | grep java`
	length=${#file[@]}
	if [ $length -gt 0  ];then 
	yum remove -y ${file[0]}
	else
	echo "删除完毕！"
		break
	fi
done

ps -auxf | grep 'uninstall_java.sh' | grep -v grep | awk '{print $2}'| xargs kill -9

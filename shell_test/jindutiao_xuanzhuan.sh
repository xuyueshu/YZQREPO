#!/bin/bash
# 进度条,动态时针版本
# 定义一个显示进度的函数,屏幕快速显示|  / ‐ \
rotate_line(){
INTERNAL=0.1
COUNT="0"
while :
do	
	COUNT=`expr $COUNT + 1` ###执行循环,COUNT 每次循环加 1,(分别代表4种不同的形状)
	##expr命令是一个手工命令行计数器，用于在UNIX/LINUX下求表达式变量的值，一般用于整数值，也可用于字符串。
	case $COUNT in
"1")					  #值为 1 显示‐
	echo -e  '‐'"\b\c" 
	sleep 0.2
	;;
"2")                      #值为 2 显示\\,第一个\是转义
	echo -e  '\\'"\b\c" 
	sleep 0.2
	;;
"3")
    echo -e "|\b\c"
    sleep 0.2
    ;;
	 
"4")
	echo -e "/\b\c"
    sleep 0.2
    ;;
*)                      #值为其他时,将 COUNT 重置为 0
	COUNT="0"
	;;
esac
done
	
}
rotate_line

## 停止死循环 ps auxf|grep 'jindutiao_xuanzhuan.sh'|grep -v grep|awk '{print $2}'|xargs kill -9 
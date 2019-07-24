#!/bin/bash
#排序
#依次输入3个整数，脚本由小到大的顺序
read -p "请输入一个整数": num1
read -p "请输入一个整数": num2
read -p "请输入一个整数": num3

tmp=0

#如果 num1 大于 num2,就把 num1 和和 num2 的值对调,确保 num1 变量中存的是最小值
if [ $num1 -gt $num2 ];then
	tmp=$num1
	num1=$num2
	num2=$tmp
	
fi

# 如果 num1 大于 num3,就把 num1 和 num3 对调,确保 num1 变量中存的是最小值

if [ $num1 -gt $num3 ];then
	tmp=$num1
	num1=$num3
	num3=$tmp

fi

# 如果 num2 大于 num3,就把 num2 和 num3 对调,确保 num2 变量中存的是比num3小的值

if [ $num2 -gt $num3 ];then
	tmp=$num2
	num2=$num3
	num3=$tmp
	
fi

echo "由小到大排序为：$num1 $num2 $num3"
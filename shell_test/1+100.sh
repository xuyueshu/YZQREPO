#!/bin/bash
##用脚本计算1+2+..+100的值
num=0
totalnum=0
while [ $num -le 100 ]
do
	echo "此时的num为：$num"
	totalnum=$(($totalnum+$num))
	echo "此时的总和为：$totalnum"
	let num=$num+1
done
echo "总和是：$totalnum"

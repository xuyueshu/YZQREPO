#!/bin/bash
##统计linux进程的相关数量
running=0
sleeping=0
stoped=0
zombie=0
# 在 proc 目录下所有以数字开始的都是当前计算机正在运行的进程的进程 PID
# 每个 PID 编号的目录下记录有该进程相关的信息
for pid in /proc/[1-9]*
do
	procs=$((procs+1))
	stat=$(awk '{print $3}' $pid/stat)
	case $stat in
	R)
		((running+=1))
		;;
	T)
		((stoped+=1))
		;;
	S)
		((sleeping+=1))
		;;
	Z)
		((zombie+=1))
		;;
	esac
done
echo "进程统计结果如下："
echo "进程总数为：$procs"
echo "运行中进程的数量为：$running"
echo "休眠中进程的数量为：$sleeping"
echo "已停止进程的数量为：$stoped"
echo "僵尸进程的数量为：$zombie"
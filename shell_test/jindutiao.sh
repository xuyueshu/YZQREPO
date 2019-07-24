#!/bin/bash
##编写脚本，显示进度条
jindu(){
while :
do
	echo -n '#'
	sleep 0.2
done
}

jindu &
## &表示后台运行
cp -a $1 $2
killall $1
echo "拷贝完成！"
##(while：)表示条件为真，死循环 

## ps auxf|grep 'jindutiao.sh'|grep -v grep|awk '{print $2}'|xargs kill -9 停止该死循环脚本
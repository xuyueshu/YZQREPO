#!/bin/bash
#编写批量修改扩展名脚本,如批量将 txt 文件修改为 doc 文件 
# 执行脚本时,需要给脚本添加位置参数
# 脚本名  txt  doc(可以将 txt 的扩展名修改为 doc)
# 脚本名  doc  jpg(可以将 doc 的扩展名修改为 jpg)

for i in `ls *.$1`
do
	if [ -z $i ];then    ## if -z判断是否为空
		echo "不存在该类文件"
	else
		mv $i ${i%.*}.$2
	fi
done





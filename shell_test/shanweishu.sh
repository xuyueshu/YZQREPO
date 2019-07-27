#!/bin/bash
##生成111-999三位数文件
for i in {1..9}
do
	for j in {1..9}
	do
		for k in {1..9}
		do
			mkdir -p /tmp/you
			touch /tmp/you/$i$j$k.txt
		done	
	done
done

ls /tmp/you
sleep 1
rm -rf /tmp/you/*
echo "####已经完全删除#####"
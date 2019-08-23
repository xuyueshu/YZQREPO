#!/bin/bash
##使用脚本安装jdk
for i in {30..32}
do
	scp /etc/profile root@192.168.89.$i:/etc/
	ssh root@192.168.89.$i
	cd /opt/soft
	tar -zxvf jdk1.8.0_111-linux-x64.tar.gz
	source /etc/profile
	echo `java -version`
	logout
done



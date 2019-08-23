#!/bin/bash
##使用脚本操作mysql
user=root
passwd=sunmnet@123
host=116.62.109.76

#databases=
mysql -u$user -h$host -p$passwd <<EOF 2>/dev/null
	create database test;

EOF
##echo $databases

  
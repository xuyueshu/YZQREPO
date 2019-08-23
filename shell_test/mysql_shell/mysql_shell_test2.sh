#!/bin/bash
##脚本操作mysql
host=116.62.115.231
user=root
passwd=sunmnet@123
mysql -u$user -h$host -p$passwd <<EOF 2</dev/null
	use test;
	create table telephone(id int ,name varchar(10),phonenum varchar(20),primary key(id));

EOF
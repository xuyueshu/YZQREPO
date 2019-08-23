#!/bin/bash
##脚本操作mysql
host=116.62.115.231
user=root
passwd=sunmnet@123
db=test
table=telephone

mysql -u$user -h$host -p$passwd <<EOF 2</dev/null
	use $db;
	insert into $table values(1,'man1','15127823132'),(2,'man2','12671261352'),(3,'man3','12635136531');
	exit;
EOF
echo "执行完成！"
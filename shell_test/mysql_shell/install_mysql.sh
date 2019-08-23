#!/bin/bash
##脚本一键安装mysql


for i in `rpm -qa | grep mysql`;
do
	if [ -z $i ]
	do
		rpm -e $i --nodeps
	done
	fi
	
done 
echo "已完成卸载自带的mysql"

cd /opt/mysql
rpm -ivh mysql-community-common-5.7.13-1.el6.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.13-1.el6.x86_64.rpm
rpm -ivh mysql-community-client-5.7.13-1.el6.x86_64.rpm
rpm -ivh mysql-community-server-5.7.13-1.el6.x86_64.rpm

test &? -eq "0" && /etc/init.d/mysqld start
/etc/init.d/mysqld stop && mysqld_safe --user=mysql --skip-grant-tables & 
echo -e“\n” #回车
newpwd=Sunmnet@123
sql1="update user set authentication_string=password($sql1) , Host= '%' where user= 'root';"

 /usr/bin/expect <<EOF
set timeout 30 
spawn mysql -uroot -p 

expect {
	"password" {send "sunmnet@123\r";exp_continue;}
	"mysql>" {send "$sql1\r"; exp_continue;}
	"mysql>" {send "flush privileges\r"}
	"mysql>" {send "exit"}
}


EOF
/etc/init.d/mysqld stop
mv /etc/my.cnf  /etc/my.cnf.bak && mv /opt/mysql/my.cnf /etc/ && mv /var/lib/mysql  /data/

service mysqld start
############################
mysql -uroot -pSunmnet@123 -e "set global validate_password_policy=0"
mysql -uroot -pSunmnet@123 -e "set global validate_password_length=1"


;
 set password=password("youpassword");
alter user 'root'@'%' identified by 'Sunmnet@123';
flush privileges;


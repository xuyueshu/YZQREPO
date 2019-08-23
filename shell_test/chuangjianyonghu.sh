#!/bin/bash
##通过自定义的用户文件，密码文件创建用户和密码

read -p "请选择操作选项：create/delete  " operation

suffix=/root/you/shell_test
case $operation in 
create)
		read -p "请输入用户文件：" file1
		userfile=${suffix}/${file1}
		[ -e $userfile ] || {
		echo $userfile
			echo "你输入的文件不存在！"
			exit 1
		}
		
		read -p "请输入密码文件: " file2 
		passwdfile=${suffix}/${file2}
		[ -e $passwdfile ] || {
			echo "你输入的文件不存在！"
			exit 1
		}
		
		userline=`awk 'BEGIN{N=0}{N++} END{print N}' $userfile`  ##计算用户文件的行数
		echo "userline=$userline"
		for line_num in `seq 1 $userline`
		do
			username=$(sed -n "${line_num}p" $userfile) ##截取指定的第几行
			userpasswd=$(sed -n "${line_num}p" $passwdfile)
			useradd $username
			echo "用户 $username 已创建成功！" 
			echo $userpasswd | passwd --stdin $username
			echo "用户 $username 的密码已设置好！"
			
		done
		;;
delete)
		
		read -p "请输入用户文件：" file1
		userfile=${suffix}/${file1}
		[ -e $userfile ] || {
			echo "你输入的文件不存在！"
			exit 1
		}
		
		read -p "请输入密码文件: " file2
		passwdfile=${suffix}/${file2}
		[ -e $passwdfile ] || {
			echo "你输入的文件不存在！"
			exit 1
		}
		
		userline=`awk 'BEGIN{N=0}{N++} END{print N}' $userfile`
		for line_num in `seq 1 $userline`
		do
			username=`sed -n "${line_num}p" $userfile`
			userdel -r $username
			echo "用户 $username 已经删除"
			
		done
		;;

*)
	echo "输入错误！请按规定输入！"
	;;	
esac

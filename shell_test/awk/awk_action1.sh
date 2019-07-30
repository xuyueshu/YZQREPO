#!/bin/bash
##awk 的action文件，命令：awk -v n=2 -f awk_action1.sh text.txt
##使用-v选项，它允许你在BEGIN代码段之前设定变量。在命令行上，-v选项必须放在脚本代码之前：

BEGIN {print "this optionvalue is",n;FS=","} {print $n}
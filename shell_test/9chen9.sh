#!/bin/bash
##九九乘法表

for i in `seq 9`
do
  	for j in `seq $i`
   	do
       	echo -n "$j*$i=$[i*j]  "  #echo -n 不换行输出   echo -e 处理特殊字符若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文 字输出：
   	done
    echo
done
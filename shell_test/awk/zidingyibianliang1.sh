#!/bin/bash
##awk 自定义变量1
awk 'BEGIN {
x=1;
print x;
x=x+1;
print x;
x=2*x+1;
print x
}'

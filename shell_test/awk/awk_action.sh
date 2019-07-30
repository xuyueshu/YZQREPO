#!/bin/bash
## awk的action文件  命令行执行awk -f awk_action.sh n=2 ../text.txt 
BEGIN {FS=","} {print $n}
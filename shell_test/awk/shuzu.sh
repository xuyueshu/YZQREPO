#!/bin/bash
##awk中数组
awk 'BEGIN{
VAR["A"]=1;
VAR["B"]=2;
VAR["C"]=3;
VAR["D"]=4;
for (ele in VAR){
	print "index:",ele,",value:",VAR[ele]
}
}'

izbp14zz7mx8kss1n6flq7z


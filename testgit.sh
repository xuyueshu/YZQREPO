#!/bin/bash
#test github
#by authors youzhiqiang 2019
NUM1=$1
NUM2=$2
if (( $NUM1>$NUM2 ));then
	echo -e "\033[32m$NUM1 bigger than $NUM2\033[0m"
else

	echo -e "\033[32m$NUM1 smaller than $NUM2\033[0m"
fi

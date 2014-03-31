#!/bin/bash


log=/tmp/check_mem.log

#$(date) \n $(free -lm | grep 'Mem\|Swap')"

start=$(date +"%M")

while true
do

minute=$(date +"%M")
num=$(expr $minute - $start)

#echo ">>>>>>>>>>>>>>>>>>>" >> $log

if [ $num != 59  ] ; then

mem=$(free -lm | grep 'Mem')

usage=$(free -lm | grep 'Mem' | awk '{print $4}')

if [ "$usage" -ge 250 ]; then
	echo "SAFE" >> /dev/null
	#ps aux | awk '{print $2, $4, $11}' | sort -k2r | head -n 10 >> $log
else
	echo ">>>>>>>>>>>>>>>>>>>" >> $log
	echo "BAD" >> $log
	#ps aux | awk '{print $2, $4, $11}' | sort -k2r | head -n 10 >> $log
	ps aux | awk '{print $2, $4,$6,substr($0, index($0,$11))}' | sort -k2nr | head -n 50 >> $log

	cat /proc/meminfo >> $log
	echo "----" >> $log

	cache=$(free -lm | grep 'buffers')

	swap=$(free -lm | grep 'Swap')


	echo "$(date)" >> $log
	echo $mem >> $log
	echo $cache >> $log
	echo $swap >> $log

sleep 2

fi

else
	#echo "END $(date)"
	exit 0
fi


done

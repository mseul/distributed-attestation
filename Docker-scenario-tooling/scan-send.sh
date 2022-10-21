#!/bin/bash

if [ "$1" == "" ]; then
	echo "ERROR: Must specify number of nodes as first parameter."
	exit 1
fi

for i in $(eval echo {1..$1})
do	
	if [ -f "/tmp/Node$i.done" ]; then
		echo "Node$i already done. Skipping."
		continue
	fi
	echo "Dispatching Node$i..."
	echo "QueryStart=$(awk 'NR==3 {print $3}' /proc/timer_list)" >/tmp/Node$i.log
	payload=$(echo "SCAN_NOW_NODE#i" | sha256sum)
	while :
	do
		echo $payload | /dtn7/bin/dtnsend -l 3660 -r dtn://Node$i/oscap &>>/tmp/dtnsend.log
		if [ $? -eq 0 ]; then
			break
		fi
		sleep 1
	done
	
	echo "QuerySent=$(awk 'NR==3 {print $3}' /proc/timer_list)" >>/tmp/Node$i.log	
done

sleep 1

#!/bin/bash
stop_file=./watcher.stop
watcher_log=./watcher.log

rm -f $stop_file
rm -f $watcher_log

while :
do
	vmstat -t | awk 'NR==3' >>$watcher_log
	if test -f "$stop_file"; then
		break
	fi
	sleep 1
done

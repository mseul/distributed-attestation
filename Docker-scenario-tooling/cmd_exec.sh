#!/bin/bash

echo "QueryStart=$(awk 'NR==3 {print $3}' /proc/timer_list)" >/tmp/Node$1.log
/dtn7/bin/dtnsend -l 9000 -r dtn://Node$1/incoming /etc/dtnoscap/scan_payload.txt
echo "QuerySent=$(awk 'NR==3 {print $3}' /proc/timer_list)" >>/tmp/Node$1.log	

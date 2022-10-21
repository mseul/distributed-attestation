#!/bin/bash
echo DONE >/tmp/$nID.done
recvstamp=$(awk 'NR==3 {print $3}' /proc/timer_list)
nID=$(echo $1 | grep -o "Node[0-9]*")
echo "QueryResponse=$recvstamp" >>/tmp/$nID.log
echo "SHA256=$(sha256sum $2)" >>/tmp/$nID.log

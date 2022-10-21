#!/bin/bash

nodesFile=$(cat /tmp/nodeips.txt)
for nodeIP in $nodesFile
do
	/etc/scanclassic/cmd_exec.sh $nodeIP &
done < /tmp/nodeips.txt

sleep 1

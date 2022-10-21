#!/bin/bash
totalNodes=$1
criterion=$2

echo "Looking for $criterion ..."

for i in $(eval echo {1..$totalNodes})
do
	echo "Node$i"
	sudo podman exec Node$i cat /tmp/dtnd.log | grep $criterion
done

echo "Controller"
sudo podman exec Controller cat /tmp/dtnd.log | grep $criterion

echo "Done."

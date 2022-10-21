#!/bin/bash
echo "CONTROLLER AUTO-LOG-TAIL v2 - Matt Seul (mxs231@shsu.edu)"
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Looking for Controller session to attach to. Hold CTRL+C to exit."

while :
do
	sudo podman container inspect Controller &>/dev/null
	if [ $? -eq 0 ]
	then
		echo "Session found. Connecting..."
		echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		sudo podman exec Controller tail -F /tmp/dtnd.log
		echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		echo "Controller session ended. Resuming in 3sec. Press CTRL+C to exit."
		sleep 3
		echo "Looking for Controller session to attach to..."
	else
		sleep 1
	fi
done

#!/bin/bash


cleanup() {
	echo -n "Cleaning up session environment"

	rm -f ./runner.conclude
	echo -n "."
	rm -f ./session.ready
	echo -n "."
	
	touch ./watcher.stop
	echo -n "."
	sleep 2
	rm -f ./watcher.log
	echo -n "."
	
	rm -f ./trigger_launch.log
	echo -n "."

	rm -f ./scenario.log
	echo -n "."
	rm -f ./scenario.csv
	echo -n "."
	rm -f ./walltime.txt
	echo -n "."
	rm -f ./watcher.log
	echo -n "."
	rm -f ./build_scenario.log
	echo -n "."
	rm -f ./nodeips.txt
	echo -n "."
	rm -f ./node_known_hosts.txt
	echo -n "."
	echo "Done."
}


echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Scenario Orchestrator v4 - Matt Seul (mxs231@shsu.edu)"
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


if [ "$1" == "" ]
then
	echo "Use first parameter to specify which script to use as main scenario driver."
	exit 1
fi

desiredCycles=0

if [ "$2"=="" ]
then
	desiredCycles=10
fi

echo "WARNING! THIS WILL STOP AND DELETE ALL RUNNING CONTAINERS!"
echo "Press CTRL+C to exit within 3sec."
sleep 3


echo "Cycles to conduct: $desiredCycles"

cycleNum=0

while :
do
	((cycleNum=cycleNum+1))
	while :
	do
		if [ -f "./session.stop" ]
		then
			echo "session.stop file still present from previous or ongoing run. Please clean up. Will sleep for 10sec..."
			sleep 10
			continue
		fi
		break
	done
	
	cleanup

	echo "Starting session builder..."
	./build-scenario.sh &>./build_scenario.log &
	
	echo -n "Waiting for session.ready file to appear..."

	while :
	do
		if [ -f "./session.ready" ]
		then
			break
		fi
		
		echo -n "."
		sleep 1
	done

	echo "Success."
	
	rm -f ./session.stop
	rm -f ./session.ready
	
	echo "Running Scenario..."
	
	if [ $1 -eq 1 ]
	then
		./run-scenario.sh &>./scenario.log
	fi
	
	if [ $1 -eq 2 ]
	then
		./run-scenario2.sh &>./scenario.log
	fi
	
	echo "Scenario run completed."
	
	echo -n "Signalling builder to stop session"
	touch ./session.stop

	while :
	do
		if [ -f "./session.stop" ]
		then
			echo -n "."
			sleep 1
			continue
		fi
		
		break
	done
	
	echo "Completed."
	
	if [ -f "./orchestrator.conclude" ]
	then
		echo "Signal received to exit early. Concluding..."
		rm -f ./orchestrator.conclude
		break
	fi
	
	if [ $cycleNum -ge $desiredCycles ]
	then
		echo "Desired Number of Cycles ($cycleNum / $desiredCycles) reached. Concluding..."
		break
	fi
	
	echo "Cooldown of 130sec before restarting cycle. Press CTRL+C to stop..."
	sleep 130
done

echo "Orchestration concluded."


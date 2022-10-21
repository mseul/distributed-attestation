#!/bin/bash
echo "SCENARIO RUNNER v12 - Matt Seul (mxs231@shsu.edu)"
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "INITIALIZING DTN7 NETWORK..."
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#totalNodes=10 #for delay runs
totalNodes=50 #for loopback runs


echo "Setting up Controller..."
sudo podman exec -d "Controller" /etc/dtnoscap/runner-sink.sh >/dev/null
sudo podman exec -d "Controller" rm -f /tmp/Node*.log >/dev/null
sudo podman exec -d "Controller" rm -f /tmp/*.done >/dev/null
nodesDone=$(sudo podman exec Controller ls /tmp/ | grep done | wc -l)
if [ $nodesDone -gt 0 ]
then
	echo "Remnant $nodesDone DONE files in Controller directory. Aborting."
	exit 1
fi

#echo "Setting up Hopper..."
#sudo podman exec -d "Controller" /etc/dtnoscap/runner.sh Hopper >/dev/null

sleep 3

rm -f ./trigger_launch.log
touch ./trigger_launch.log

echo -n "Starting DTN7 on Client Containers"
for i in $(eval echo {1..$totalNodes})
do
	while :
	do
		sudo podman exec -d "Node$i" /etc/dtnoscap/runner.sh Node$i &>>./trigger_launch.log
		if [ $? -eq 0 ]
		then
			break
		fi
		echo -n "X"
		sleep 1
	done
	
	echo -n "."
done
echo "Done."

echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "VALIDATING SCENARIO..."
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo -n "Validating all Nodes connected to DTN7 network..."
while :
do
	peercount=$(sudo podman exec Controller /dtn7/bin/dtnquery peers | grep -o "//Node[0-9]*" | wc -l)
	if [ $peercount -eq $totalNodes ]
	then
		break
	fi
	echo -n "."
	sleep 1
done

echo "Succeeded."

echo -n "Ensuring DTN7 Node Trigger Enrollment"

while :
do
	didFix=0
	for i in $(eval echo {1..$totalNodes})
	do
		while :
		do	
			psquery=$(sudo podman exec Node$i ps)
			echo $psquery | grep "/dtn7/bin/dtntrigger" >/dev/null
			if [ $? -eq 0 ]
			then
				echo -n "."
				break
			fi
			echo -n "$i"
			#echo "Node $i not attached. Rerunning the attachment command."
			#sudo podman exec -d "Node$i" /etc/dtnoscap/runner.sh Node$i >/dev/null
			#didFix=1 #Uncomment to do double-take verification.
			sleep 5
		done
	done
	if [ $didFix -eq 0 ]
	then
		break
	fi
	
	echo "At least one Node required re-attaching. Running another pass to ensure environment is fully up."
done

echo "Ready."


echo -n "Allowing system to settle for 60 seconds..."
sleep 60
echo "Done"


echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "LAUNCHING SCENARIO..."
echo $(date)
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo "Spawning Host resource watcher..."
./res_watch.sh &

echo "Broadcasting Scan command via Controller..."
launchTime=$(sudo awk 'NR==3 {print $3}' /proc/timer_list)
sudo podman exec -d "Controller" /etc/dtnoscap/scan-send.sh $totalNodes >/dev/null

cyclesDone=0
cyclesWait=10
cyclesMax=1000
if [ $cyclesWait -gt 0 ]
then
	echo "Snoozing DTN7 bundle queries for $cyclesWait seconds to avoid slamming the Controller."
fi

while :
do
	if [ $cyclesDone -gt $cyclesWait ]
	then
		#nodesDone=$(sudo podman exec Controller ls /tmp/ | grep done | wc -l)
		nodesDone=$(sudo podman exec Controller /dtn7/bin/dtnquery bundles | grep Node | wc -l)
		echo "$nodesDone/$totalNodes done."
		if [ -f ./runner.conclude ]
		then
			echo "Signal received to exit early. Concluding..."
			rm -f ./runner.conclude
			break
		fi
		
		if [ $nodesDone -eq $totalNodes ]
		then
			break
		fi 
	fi
	
	if [ $cyclesDone -gt $cyclesMax ]
	then
		echo "maxCycles of $maxCycles hit. Bailing out."
		echo "$(date) cyclesMax hit at $nodesDone/$totalNodes done." >>./bailout.log
		break
	fi
		
	cyclesDone=$((cyclesDone+1))
	sleep 1
done

endTime=$(sudo awk 'NR==3 {print $3}' /proc/timer_list)
totalTimeNS=$(($endTime-$launchTime))
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo $(date)
echo RUN COMPLETED. FINALIZING ...
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

dateext=$(date "+%Y%m%d%H%M%S")

totalTimeMS=$((totalTimeNS/10000000))
totalTimeSec=$((totalTimeNS/1000000000))
echo "Total Cycle Time / Host Perspective - Total Time taken: $totalTimeSec (Sec) / $totalTimeMS (MS) / $totalTimeNS (NS)" >./${dateext}_walltime.txt
cat ./${dateext}_walltime.txt


echo "Stopping Host resource watcher..."
touch ./watcher.stop
sleep 2
mv ./watcher.log ./${dateext}_watcher.log


echo -n "Assembling Result CSV"
echo "Node ID,Query Start,Query Sent,Query Response,QSHA256,RSHA256">./${dateext}_scenario.csv
for i in $(eval echo {1..$totalNodes})
do
	shaAlt=$(sudo podman exec Node$i cat /tmp/scan.sum)
	log=$(sudo podman exec Controller cat /tmp/Node$i.log)
	log=${log//[![:print:]]/,}
	log=${log//QueryStart=/}
	log=${log//QuerySent=/}
	log=${log//QueryResponse=/}
	log=${log//SHA256=/}
	echo "Node$i,$log,$shaAlt">>./${dateext}_scenario.csv
	echo -n "."
done
echo "Done."


echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "SCENARIO COMPLETED."
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

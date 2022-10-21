#!/bin/bash
echo "SCENARIO2 RUNNER v7 - Matt Seul (mxs231@shsu.edu)"
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "INITIALIZING NETWORK..."
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#totalNodes=10 #for delay runs
totalNodes=50 #for loopback runs


echo -n "Setting up Controller..."
sudo podman exec -d "Controller" rm -f /tmp/Node*.log >/dev/null
sudo podman exec -d "Controller" rm -f /tmp/*.done >/dev/null
nodesDone=$(sudo podman exec Controller ls /tmp/ | grep done | wc -l)
if [ $nodesDone -gt 0 ]
then
	echo "Remnant $nodesDone DONE files in Controller directory. Aborting."
	exit 1
fi
echo "Ready."

echo -n "Starting SSH server on Client Containers"
for i in $(eval echo {1..$totalNodes})
do
	sudo podman exec -d "Node$i" /etc/init.d/dropbear start >/dev/null
	#sudo podman exec "Node$i" /etc/init.d/dropbear start >/dev/null
	echo -n "."
done
echo "Done."

sleep 3

echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "VALIDATING SCENARIO AND GATHERING NODE INFORMATION..."
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

rm -f ./nodeips.txt
touch ./nodeips.txt
rm -f ./node_known_hosts.txt
touch ./node_known_hosts.txt

echo -n "Collecting NODE IPs and validating SSH server is up"
while :
do
	didFix=0
	for i in $(eval echo {1..$totalNodes})
	do
		while :
		do	
			psquery=$(sudo podman exec Node$i ps)
			echo $psquery | grep "/usr/sbin/dropbear -r" >/dev/null
			if [ $? -eq 0 ]
			then
				ipquery=$(sudo podman exec "Node$i" ifconfig)
				nodeip=$(echo $ipquery | grep -o "10.83.0.[[0-9]*" | grep -v ".255")
				echo $nodeip >>./nodeips.txt
				rm -f ./node_key_tmp
				sudo podman cp Node$i:/etc/dropbear/dropbear_rsa_host_key ./node_key_tmp
				hostkey=$(sudo dropbearkey -y -t rsa -f ./node_key_tmp | grep ssh-rsa)
				hostkey=${hostkey// root@dockerpi/}
				echo "$nodeip $hostkey" >>./node_known_hosts.txt
				rm -f ./node_key_tmp
				echo -n "."
				break
			fi
			echo "Node $i has no SSH up. Rerunning the start command."
			sudo podman exec -d "Node$i" /etc/init.d/dropbear start >/dev/null
			#sudo podman exec "Node$i" /etc/init.d/dropbear start >/dev/null
			#didFix=1 #Uncomment to do double-take verification.
			sleep 5
		done
	done
	if [ $didFix -eq 0 ]
	then
		break
	fi
	
	echo "At least one Node required restarting sSH. Running another pass to ensure environment is fully up."
done

echo "Done."


echo -n "Validating number of gathered IPs..."
numIPs=$(cat ./nodeips.txt | wc -l)
if [ $numIPs -eq $totalNodes ]
then
	echo "Success."
else
	echo "FATAL ERROR"
	echo "Only gathered $numIPs/$totalNodes IPs. Aborting."
	exit 1
fi

echo -n "Validating number of gathered SSH Host Keys..."
numKeys=$(cat ./node_known_hosts.txt | wc -l)
if [ $numKeys -eq $totalNodes ]
then
	echo "Success."
else
	echo "FATAL ERROR"
	echo "Only gathered $numKeys/$totalNodes IPs. Aborting."
	exit 1
fi

echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "LAUNCHING SCENARIO..."
echo $(date)
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo "Spawning Host resource watcher..."
./res_watch.sh &

echo "Deploying NodeIPs file to Controller..."
sudo podman cp ./nodeips.txt Controller:/tmp/nodeips.txt

echo "Deploying SSH known_hosts file to Controller..."
sudo podman exec Controller mkdir -p /home/root/.ssh/
sudo podman cp ./node_known_hosts.txt Controller:/home/root/.ssh/known_hosts


echo "Initiating Scan command via Controller..."
launchTime=$(sudo awk 'NR==3 {print $3}' /proc/timer_list)
sudo podman exec -d "Controller" /etc/scanclassic/scan-send.sh >/dev/null

while :
do
	nodesDone=$(sudo podman exec Controller ls /tmp/ | grep done | wc -l)
	echo "$nodesDone/$totalNodes done."
	if [ -f "./runner.conclude" ]
	then
		echo "Signal received to exit early. Concluding..."
		rm -f "./runner.conclude"
		break
	fi
	if [ $nodesDone -eq $totalNodes ]
	then
		break
	fi
	
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
echo "Node ID,Query Start,Query Sent,Query Response,SHA256">./${dateext}_scenario.csv
nodesFile=$(cat ./nodeips.txt)
for nodeIP in $nodesFile
do
	log=$(sudo podman exec Controller cat /tmp/Node_$nodeIP.log)
	log=${log//[![:print:]]/,}
	log=${log//QueryStart=/}
	log=${log//QuerySent=/}
	log=${log//QueryResponse=/}
	log=${log//SHA256=/}
	echo "Node_$nodeIP,$log">>./${dateext}_scenario.csv
	echo -n "."
done
echo "Done."


echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "SCENARIO COMPLETED."
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#!/bin/bash
echo "Setting up default broadcast route for CoreEmu..."
ip link set multicast on dev eth0
route add -net 224.0.0.0 netmask 224.0.0.0 eth0
echo "Launching DTN7 Daemon..."
#/dtn7/bin/dtnd -n $1 -e oscap -C mtcp -p 10m --parallel-bundle-processing -r epidemic &>>/tmp/dtnd.log &
/dtn7/bin/dtnd -n $1 -e incoming -C mtcp -p 20m -r sprayandwait -R sprayandwait.num_copies=9 &>>/tmp/dtnd.log &
sleep 1

echo "Starting trigger recovery process..."
/etc/dtnoscap/trigger_recovery.sh &>>/tmp/trigger_recovery.log &

echo "Entering Trigger cycle..."
while :
do
	echo "Rapid registration of trigger..."
	/dtn7/bin/dtntrigger -c /etc/dtnoscap/trigger.sh -e oscap  &>>/tmp/dtntrg.log
	if [ $? -eq 0 ]; then
		break
	fi
done

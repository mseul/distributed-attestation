#!/bin/bash
echo "TriggerStart=$(awk 'NR==3 {print $3}' /proc/timer_list)" >>/tmp/trigger.log
echo "+++++++++++++++++++++++++++++" >>/tmp/trigger.log
echo "Triggering new OSCAP run..." >>/tmp/trigger.log
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_basic-embedded /usr/share/xml/scap/ssg/content/ssg-openembedded-ds.xml > /tmp/scan.log
sha256sum /tmp/scan.log >/tmp/scan.sum
sha256sum /tmp/dtnd.log >>/scan.log
echo "Sending results..." >>/tmp/trigger.log
while :
do
	/dtn7/bin/dtnsend -l 3660 -r $1oscap /tmp/scan.log &>>/tmp/trigger.log
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
done
echo "TriggerEnd=$(awk 'NR==3 {print $3}' /proc/timer_list)" >>/tmp/trigger.log

#!/bin/bash

nodeIP=$1

echo "QueryStart=$(awk 'NR==3 {print $3}' /proc/timer_list)" >/tmp/Node_$nodeIP.log
echo "QuerySent=$(awk 'NR==3 {print $3}' /proc/timer_list)" >>/tmp/Node_$nodeIP.log

scanresult=$(ssh root@$nodeIP oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_basic-embedded /usr/share/xml/scap/ssg/content/ssg-openembedded-ds.xml)
resultsha=$(echo $scanresult | grep -A 999 'Starting the evaluation...' | grep -B 999 "oscap exit code:" | sha256sum)

echo "QueryResponse=$(awk 'NR==3 {print $3}' /proc/timer_list)" >>/tmp/Node_$nodeIP.log
echo "SHA256=$resultsha" >>/tmp/Node_$nodeIP.log
echo "DONE" >/tmp/Node_$nodeIP.done

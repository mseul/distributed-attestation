#!/bin/bash

while :
do
        echo "Checking if Trigger Recovery necessary..."
        if [ -f /tmp/scan.sum ]
        then
                echo "Discovered /tmp/scan.sum. Trigger fired already. Exiting..."
                break
        fi

        echo "Pulling current packages..."
        package=$(/dtn7/bin/dtnrecv -e incoming)

        if [ "$package" == "" ]
        then
                echo "No content found in packages. Sleeping..."
                sleep 1
                continue
        fi

        echo "Content found in packages. Starting recovery..."
        echo "Received package content: $package"

        echo $package >/tmp/recovery.package

        echo "Launching Trigger via Recovery..."
        /etc/dtnoscap/trigger.sh Controller /tmp/recovery.package
        echo "Trigger fired."
        break
done

echo "Recovery mode concluded."

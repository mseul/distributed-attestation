#!/bin/bash

echo "SCENARIO BUILDER v8 - Matt Seul (mxs231@shsu.edu)"
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

rm -f ./session.stop

echo "Cleaning up CoreEmu Network and Sessions..."
sudo core-cleanup
echo "Cleaning up Containers..."
sudo podman stop -a -t 0
sudo podman rm -a
sudo python ./core-image-launcher.py

rm -f ./session.stop

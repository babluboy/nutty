#!/bin/bash
sudo nethogs $1 -t > /tmp/nutty_nethogs.txt &
sleep 10
sudo killall nethogs
cat /tmp/nutty_nethogs.txt
sudo rm /tmp/nutty_nethogs.txt

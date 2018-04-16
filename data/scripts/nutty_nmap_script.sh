#!/bin/bash
#$1=path to a temp file where the nmap xml output will be written
#$2=IP address range to scan with nmap. This should be of the form 192.168.1.1/24
sudo nmap -sn -oX $1 $2 > /dev/null

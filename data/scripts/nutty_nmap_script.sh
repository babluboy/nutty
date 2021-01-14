#!/bin/bash
#$1=path to a temp file where the nmap xml output will be written
#$2=IP address range to scan with nmap. This should be of the form 192.168.1.1/24
# Check if NMap is installed and run NMap to get XML output
if command -v nmap &> /dev/null; then
  sudo nmap -sn -oX $1 $2 > /dev/null
  echo "nmap executed successfully" 1>&2
else #raise error with message
  echo "The program nmap is not installed. Please install nmap and re-try" 1>&2
  exit 10
fi

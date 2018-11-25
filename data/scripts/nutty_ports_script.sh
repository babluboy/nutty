#!/bin/bash
#$1=name of the interface
if command -v netstat &> /dev/null; then
    netstat -p -e $1 > /tmp/nutty_ports.txt
    cat /tmp/nutty_ports.txt
    rm /tmp/nutty_ports.txt
else #raise error with message
  echo "The program netstat is not installed. Please install netstat and re-try" 1>&2
  exit 11
fi

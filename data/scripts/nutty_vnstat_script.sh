#!/bin/bash
#$1=name of the interface
if command -v vnstat &> /dev/null; then
    vnstat --xml -i $1 > /tmp/nutty_vnstat.txt
    cat /tmp/nutty_vnstat.txt
    rm /tmp/nutty_vnstat.txt
else #raise error with message
  echo "The program vnstat is not installed. Please install vnstat and re-try" 1>&2
  exit 11
fi

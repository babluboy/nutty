#!/bin/bash
#$1=URL for doing traceroute
if command -v traceroute &> /dev/null; then
    traceroute $1 > /tmp/nutty_traceroute.txt
    cat /tmp/nutty_traceroute.txt
    rm /tmp/nutty_traceroute.txt
else #raise error with message
  echo "The program traceroute is not installed. Please install traceroute and re-try" 1>&2
  exit 12
fi

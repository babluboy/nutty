#!/bin/bash
if command -v nethogs &> /dev/null; then
    sudo nethogs $1 -t > /tmp/nutty_nethogs.txt &
    sleep 10
    sudo killall nethogs
    cat /tmp/nutty_nethogs.txt
    sudo rm /tmp/nutty_nethogs.txt
else #raise error with message
  echo "The program nethogs is not installed. Please install nethogs and re-try" 1>&2
  exit 10
fi

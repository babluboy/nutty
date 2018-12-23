#!/bin/bash
#$1=mode of operation
#$2=name of the interface
if [ "$1" = "INTERFACE_HARDWARE_DETAILED" ]
then
	if command -v lshw &> /dev/null; then
        lshw -xml -class network > /tmp/nutty_hardware.txt
        cat /tmp/nutty_hardware.txt
        rm /tmp/nutty_hardware.txt
    else #raise error with message
      echo "The program lshw is not installed. Please install lshw and re-try" 1>&2
      exit 10
    fi
fi
if [ "$1" = "HOSTNAME" ]
then
	INTERFACE=`hostname`
    echo $INTERFACE
fi
if [ "$1" = "INTERFACE" ]
then
	INTERFACE=`/sbin/ip addr show | grep -Po '(?<=[\d]: ).*(?=:)'`
    echo $INTERFACE	
fi
if [ "$1" = "IP" ]
then
    IP=`/sbin/ip addr show $2 | grep -Po 'inet \K[\d.]+'`
	echo $IP
fi
if [ "$1" = "IPV6" ]
then
    IPV6=`/sbin/ip -6 addr show dev $2 | awk -F' ' '{print $2}' | awk '{print $1}'| head -n 2| tail -1 | cut -d# -f2`
	echo $IPV6
fi
if [ "$1" = "MAC" ]
then
    MAC=`/sbin/ip addr show $2 | grep -Po 'link/*(ether |loopback )\K.*(?= brd)'`
	echo $MAC
fi
if [ "$1" = "STATE" ]
then
    STATE=`/sbin/ip addr show $2 | grep -Po '(?<=state ).*(?= group)'`
	echo $STATE
fi
if [ "$1" = "INTERFACE_HARDWARE" ]
then
    lspci -v > /tmp/nutty_interface_hardware.txt
    cat /tmp/nutty_interface_hardware.txt
    rm /tmp/nutty_interface_hardware.txt
fi
if [ "$1" = "WIRELESS_CARD_DETAILS" ]
then
    WIRELESS_CARD=`iwconfig $2`
	echo $WIRELESS_CARD
fi
if [ "$1" = "WIRELESS_CARD_CHANNEL_DETAILS" ]
then
    WIRELESS_CARD_CHANNEL=`iwlist $2`
	echo $WIRELESS_CARD_CHANNEL
fi

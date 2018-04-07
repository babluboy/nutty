#!/bin/bash
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

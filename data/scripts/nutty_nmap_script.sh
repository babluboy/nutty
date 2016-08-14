#!/bin/bash
sudo nmap -sn -oX /tmp/nutty_nmap.xml $1
cat /tmp/nutty_nmap.xml
sudo rm /tmp/nutty_nmap.xml

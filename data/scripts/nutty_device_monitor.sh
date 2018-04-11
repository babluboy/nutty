#!/bin/bash
NUTTY_CONFIG_DIR=$2
CRONTAB_BACKUPFILE=$3
CRONTAB_TEMPFILE=$4
CRONTAB_15_MIN_SCHEDULE="*/15 * * * * /usr/bin/com.github.babluboy.nutty --monitor $NUTTY_CONFIG_DIR"
CRONTAB_30_MIN_SCHEDULE="*/30 * * * * /usr/bin/com.github.babluboy.nutty --monitor $NUTTY_CONFIG_DIR"
CRONTAB_60_MIN_SCHEDULE="0 * * * * /usr/bin/com.github.babluboy.nutty --monitor $NUTTY_CONFIG_DIR"
CRONTAB_1440_MIN_SCHEDULE="0 0 * * * /usr/bin/com.github.babluboy.nutty --monitor $NUTTY_CONFIG_DIR"
#This section removes any schedule for nutty device monitoring from root's crontab
sudo crontab -l > $CRONTAB_BACKUPFILE
sudo sed '/nutty/ d' $CRONTAB_BACKUPFILE > $CRONTAB_TEMPFILE
sudo crontab $CRONTAB_TEMPFILE
#This section is executed to add a nutty device monitoring for every 15 minutes
if [ "$1" = "15" ]
then
	echo "$CRONTAB_15_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	sudo crontab $CRONTAB_TEMPFILE
fi
#This section is executed to add a nutty device monitoring for every 30 minutes
if [ "$1" = "30" ]
then
	echo "$CRONTAB_30_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	sudo crontab $CRONTAB_TEMPFILE
fi
#This section is executed to add a nutty device monitoring for every hour
if [ "$1" = "60" ]
then
	echo "$CRONTAB_60_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	sudo crontab $CRONTAB_TEMPFILE
fi
#This section is executed to add a nutty device monitoring daily
if [ "$1" = "1440" ]
then
	echo "$CRONTAB_1440_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	sudo crontab $CRONTAB_TEMPFILE
fi
#Remove the temp crontab file
sudo rm $CRONTAB_TEMPFILE


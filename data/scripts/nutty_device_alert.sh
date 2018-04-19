#!/bin/bash
NUTTY_CONFIG_DIR=$2
CRONTAB_BACKUPFILE=$3
CRONTAB_TEMPFILE=$4
#Find the DISPLAY for the user (i.e. DISPLAY=:0)
DISPLAY_NUMBER=`ps -u $(id -u) -o pid= |   xargs -I{} cat /proc/{}/environ 2>/dev/null |   tr '\0' '\n' |   grep -m1 '^DISPLAY='`
#Set up the various frequency schedules
CRONTAB_15_MIN_SCHEDULE="*/13 * * * * export $DISPLAY_NUMBER && /usr/bin/com.github.babluboy.nutty --alert $NUTTY_CONFIG_DIR"
CRONTAB_30_MIN_SCHEDULE="*/28 * * * * export $DISPLAY_NUMBER && /usr/bin/com.github.babluboy.nutty --alert $NUTTY_CONFIG_DIR"
CRONTAB_60_MIN_SCHEDULE="*/55 * * * * export $DISPLAY_NUMBER && /usr/bin/com.github.babluboy.nutty --alert $NUTTY_CONFIG_DIR"
CRONTAB_1440_MIN_SCHEDULE="0 1 * * * export $DISPLAY_NUMBER && /usr/bin/com.github.babluboy.nutty --alert $NUTTY_CONFIG_DIR"
#This section removes any schedule for nutty device alerting from user's crontab
crontab -l > $CRONTAB_BACKUPFILE
sed '/nutty/ d' $CRONTAB_BACKUPFILE > $CRONTAB_TEMPFILE
crontab $CRONTAB_TEMPFILE
#This section is executed to add a nutty device alerting before every 15 minutes
if [ "$1" = "15" ]
then
	echo "$CRONTAB_15_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	crontab $CRONTAB_TEMPFILE
fi
#This section is executed to add a nutty device monitoring for every 30 minutes
if [ "$1" = "30" ]
then
	echo "$CRONTAB_30_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	crontab $CRONTAB_TEMPFILE
fi
#This section is executed to add a nutty device monitoring for every hour
if [ "$1" = "60" ]
then
	echo "$CRONTAB_60_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	crontab $CRONTAB_TEMPFILE
fi
#This section is executed to add a nutty device monitoring daily
if [ "$1" = "1440" ]
then
	echo "$CRONTAB_1440_MIN_SCHEDULE" >> $CRONTAB_TEMPFILE
	crontab $CRONTAB_TEMPFILE
fi
#Remove the temp crontab file
rm $CRONTAB_TEMPFILE


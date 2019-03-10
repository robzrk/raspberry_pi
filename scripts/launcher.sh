#/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts
LOG_PATH=/tmp/launcher.log

echo "Launcher started" > $LOG_PATH
sleep 5

echo "Scheduling debug log..." >> $LOG_PATH
lxterminal -e "sleep 500; $SCRIPTS_DIR/generate_log_email.sh" &

# Only run this launcher once per boot!
if [ -f /tmp/launcher_started ]; then
    echo "Launcher was previously started, exiting!">> $LOG_PATH
    sleep 1
    exit 1
else
    echo "first call for this boot" >> $LOG_PATH
    touch /tmp/launcher_started
fi

echo "starting vnc server..."  >> $LOG_PATH
vncserver :1

echo "Updating repo..." >> $LOG_PATH
$SCRIPTS_DIR/update_repo.sh

IPADDR=`ifconfig | grep wlan0 -A 5 | grep inet | grep -v inet6 | awk '{ print $2 }'`
echo "Started VNC server at ${IPADDR}:1 ..." >> $LOG_PATH

sleep 1 

echo "Waiting for systemd-timesyncd to start..." >> $LOG_PATH
RC=-1
while [ $RC -ne 0 ]; do
    ps -ef | grep systemd-timesyncd | grep -v grep > /dev/null
    RC=$?
    sleep 1
done

echo "Waiting for date to be updated ..." >> $LOG_PATH
DATE_SYNCED=""
while [ "$DATE_SYNCED" != "yes" ]; do 
    DATE_SYNCED=`timedatectl | grep sync | awk '{ print $3 }'`
    sleep 1
done

echo "Reading the lastest emails ..." >> $LOG_PATH
$SCRIPTS_DIR/read_email.py
log "Refreshing background"
pcmanfm --set-wallpaper $SCRIPTS_DIR/daily_photo

echo "Launching pi_ui ..." >> $LOG_PATH
nohup lxterminal -e sh -c "$SCRIPTS_DIR/pi_ui.sh 2> /tmp/pi_ui_errors.log"

exit 0

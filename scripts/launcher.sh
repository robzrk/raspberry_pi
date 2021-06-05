#/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts
LOG_PATH=/tmp/launcher.log

echo "Launcher started" >> $LOG_PATH

# Only run this launcher once per boot!
if [ -f /tmp/launcher_started ]; then
    echo "Launcher was previously started, exiting!">> $LOG_PATH
    exit 1
else
    echo "first call for this boot" >> $LOG_PATH
    touch /tmp/launcher_started
fi

echo "Launching startup_message.sh ..." >> $LOG_PATH
nohup lxterminal -e $SCRIPTS_DIR/startup_message.sh

echo "starting vnc server..."  >> $LOG_PATH
vncserver :1 | tee -a $LOG_PATH

IPADDR=`ifconfig | grep wlan0 -A 5 | grep inet | grep -v inet6 | awk '{ print $2 }'`
echo "Started VNC server at ${IPADDR}:1 ..." >> $LOG_PATH

echo "Waiting for systemd-timesyncd to start..." >> $LOG_PATH
RC=-1
while [ $RC -ne 0 ]; do
    ps -ef | grep systemd-timesyncd | grep -v grep > /dev/null
    RC=$?
    sleep 1
done

echo "Waiting for date to be updated ..." >> $LOG_PATH
DATE_SYNCED=""
CNT=0
TO=120
while [ "$DATE_SYNCED" != "yes" ]; do 
    DATE_SYNCED=`timedatectl | grep sync | awk '{ print $3 }'`
    sleep 1
    if [ $CNT -eq $TO ]; then
        log "Failed to sync timedatectl."
        nohup lxterminal -e $SCRIPTS_DIR/connection_message.sh
    fi
    CNT=$(( CNT + 1 ))
done

echo "Updating repo..." >> $LOG_PATH
$SCRIPTS_DIR/update_repo.sh | tee -a $LOG_PATH

echo "Launching pi_ui ..." >> $LOG_PATH
nohup lxterminal -e sh -c "/home/pi/raspberry_pi/scripts/pi_gui.py"

exit 0

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

ntpdate -d us.pool.ntp.org

echo "Reading the lastest emails ..." >> $LOG_PATH
$SCRIPTS_DIR/read_email.py

echo "Launching pi_ui ..." >> $LOG_PATH
nohup lxterminal -e $SCRIPTS_DIR/pi_ui.sh

exit 0

#/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts
date >> /tmp/launcher_log
# Only run this launcher once per boot!
if [ -f /tmp/launcher_started ]; then
    exit 
else
    touch /tmp/launcher_started
fi
#disown -a

echo "running!" >> /tmp/launcher_log

vncserver :1

echo "Updating repo ..."
$SCRIPTS_DIR/update_repo.sh

IPADDR=`ifconfig | grep wlan0 -A 5 | grep inet | grep -v inet6 | awk '{ print $2 }'`
echo "Started VNC server at ${IPADDR}:1 ..."

sleep 1 

echo "Reading the lastest emails ..."
$SCRIPTS_DIR/read_email.py

echo "Launching pi_ui ..."
lxterminal -e $SCRIPTS_DIR/pi_ui.sh

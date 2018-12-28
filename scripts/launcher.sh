#/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts
LOG_PATH=/tmp/launcher.log

function log() {
    local LOG_MSG=$1
    echo $LOG_MSG
    echo "`date`: $LOG_MSG" >> $LOG_PATH
}

log "Launcher started"

log "Scheduling debug log..."
lxterminal -e "sleep 500; $SCRIPTS_DIR/generate_log_email.sh" &

# Only run this launcher once per boot!
if [ -f /tmp/launcher_started ]; then
    log "Launcher was previously started, exiting!"
    sleep 1
    exit 1
else
    log "first call for this boot"
    touch /tmp/launcher_started
fi

log "starting vnc server..."
vncserver :1

log "Updating repo..."
$SCRIPTS_DIR/update_repo.sh

IPADDR=`ifconfig | grep wlan0 -A 5 | grep inet | grep -v inet6 | awk '{ print $2 }'`
log "Started VNC server at ${IPADDR}:1 ..."

sleep 1 

log "Reading the lastest emails ..."
$SCRIPTS_DIR/read_email.py

log "Launching pi_ui ..."
nohup lxterminal -e $SCRIPTS_DIR/pi_ui.sh

exit 0

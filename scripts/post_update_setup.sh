#!/bin/bash
LOG_PATH=/tmp/post_update_setup.log

function log() {
    local LOG_MSG=$1
    echo "`date`: $LOG_MSG" >> $LOG_PATH
}

sudo apt-get update | tee -a $LOG_PATH

which sendmail > /dev/null
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing sendmail"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install sendmail | tee -a $LOG_PATH
fi

apt list ssmtp | grep ssmtp | grep -i installed
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing ssmtp"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install ssmtp | tee -a $LOG_PATH
fi

apt list mailutils | grep mailutils | grep -i installed
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing mailutils"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install mailutils | tee -a $LOG_PATH
fi

log "Installing ssmtp.conf"
sudo cp ~/raspberry_pi/install/ssmtp.conf /etc/ssmtp/ssmtp.conf | tee -a $LOG_PATH

log "Done!"

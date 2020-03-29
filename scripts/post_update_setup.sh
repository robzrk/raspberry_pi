#!/bin/bash
LOG_PATH=/tmp/post_update_setup.log

function log() {
    local LOG_MSG=$1
    echo "`date`: $LOG_MSG" >> $LOG_PATH
}

sudo apt-get update

which sendmail > /dev/null
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing sendmail"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install sendmail
fi

apt list ssmtp | grep ssmtp | grep -i installed
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing ssmtp"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install ssmtp
fi

apt list mailutils | grep mailutils | grep -i installed
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing mailutils"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install mailutils
fi

log "Installing ssmtp.conf"
sudo cp ../install/ssmtp.conf /etc/ssmtp/ssmtp.conf

log "Done!"

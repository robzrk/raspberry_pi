#!/bin/bash
LOG_PATH=/tmp/post_update_setup.log

function log() {
    local LOG_MSG=$1
    echo "`date`: $LOG_MSG" >> $LOG_PATH
}

which sendmail > /dev/null
if [ $? -eq 0 ]; then
    log "Nothing to do"
else
    log "Installing sendmail"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y install sendmail
fi

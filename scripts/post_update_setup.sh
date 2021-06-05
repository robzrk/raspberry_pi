#!/bin/bash
LOG_PATH=/tmp/post_update_setup.log

function log() {
    local LOG_MSG=$1
    echo "`date`: $LOG_MSG" >> $LOG_PATH
}

function check_install_package() {
    PACKAGE=$1
    apt list $PACKAGE | grep $PACKAGE | grep -i installed
    if [ $? -eq 0 ]; then
        log "Nothing to do"
    else
        log "Installing $PACKAGE"
        export DEBIAN_FRONTEND=noninteractive
        sudo apt-get -y install $PACKAGE | tee -a $LOG_PATH
    fi
}

function check_install_pip_package() {
    PACKAGE=$1
    cat /tmp/pip3_packages | grep $PACKAGE
    if [ $? -eq 0 ]; then
        log "Nothing to do"
    else
        log "Installing $PACKAGE"
        sudo pip3 install $PACKAGE | tee -a $LOG_PATH
    fi
}

###
# main
###
sudo apt-get update | tee -a $LOG_PATH

check_install_package "sendmail"
check_install_package "ssmpt"
check_install_package "python3-tk"

log "Installing ssmtp.conf"
sudo cp ~/raspberry_pi/install/ssmtp.conf /etc/ssmtp/ssmtp.conf | tee -a $LOG_PATH

python3 -m pip install --upgrade pip | tee -a $LOG_PATH
python3 -m pip install --upgrade Pillow | tee -a $LOG_PATH

pip3 list > /tmp/pip3_packages
check_install_pip_package "guizero"
check_install_pip_package "guizero[images]"
check_install_pip_package "beautifulsoup4"
check_install_pip_package "pytz"
check_install_pip_package "python-dateutil"
check_install_pip_package "imapclient"

log "Done!"

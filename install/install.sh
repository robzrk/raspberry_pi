#!/bin/bash
set -x

if [ "$1" == "" ]; then
    echo "Must specify group name!"
    cat ~/raspberry_pi/etc/email_addr_config.ini | grep -A 15 "allowable_emails"
    exit 1
fi
MY_GROUP=$1
echo $MY_GROUP > ~/my_group

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y install imagemagick
sudo apt-get -y install terminator
sudo apt-get -y install pigpio python-pigpio python3-pigpio

sudo pip install imapclient
sudo pip install email
sudo pip install configparser
sudo pip install python-dateutil

mkdir ~/.config/openbox
cp ~/raspberry_pi/install/lxde-pi-rc.xml ~/.config/openbox/
cp ~/raspberry_pi/install/lxterminal.conf ~/.config/lxterminal/

cp ~/raspberry_pi/install/.profile ~/ 

sudo cp ~/raspberry_pi/install/lxpolkit.desktop /etc/xdg/autostart/
cd
tar xf ~/raspberry_pi/install/LCD-show-*.tar.gz
cd LCD-show
./LCD35-show


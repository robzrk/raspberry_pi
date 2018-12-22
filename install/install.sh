#!/bin/bash
set -x
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y install imagemagick
sudo apt-get -y install terminator

sudo pip install imapclient
sudo pip install email
sudo pip install configparser
sudo pip install python-dateutil

mkdir ~/.config/openbox
cp ~/raspberry_pi/install/lxde-pi-rc.xml ~/.config/openbox/
cp ~/raspberry_pi/install/lxterminal.conf ~/.config/lxterminal/

sudo cp ~/raspberry_pi/install/rc.local /etc/

cd
tar xf ~/raspberry_pi/install/LCD-show-*.tar.gz
cd LCD-show
./LCD35-show


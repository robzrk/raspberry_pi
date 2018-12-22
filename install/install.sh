#!/bin/bash
set -x
sudo apt-get update
sudo apt-get install imagemagick
sudo apt-get install terminator

sudo pip install imapclient
sudo pip install email
sudo pip install configparser
sudo pip install python-dateutil

mkdir ~/.config/openbox
cp ~/raspberry_pi/install/lxde-pi-rc.xml ~/.config/openbox/
cp ~/raspberry_pi/install/lxterminal.conf ~/.config/lxterminal/

cd
tar xf ~/raspberry_pi/install/LCD-show-*.tar.gz
cd LCD-show
./LCD35-show

#~/LCD-show/LCD35-show 90

#!/bin/bash
cd ~/raspberry_pi

git reset --hard HEAD
git pull

~/raspberry_pi/scripts/post_update_setup.sh

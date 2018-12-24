#!/bin/bash
cd ~/raspberry_pi
git stash 
git reset --hard HEAD
git pull
git stash pop

~/raspberry_pi/scripts/post_update_setup.sh

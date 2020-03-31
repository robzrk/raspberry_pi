#!/bin/bash
LOG_PATH="/tmp/update_repo.log"

cd ~/raspberry_pi

git reset --hard HEAD | tee -a $LOG_PATH
git pull | tee -a $LOG_PATH

~/raspberry_pi/scripts/post_update_setup.sh | tee -a $LOG_PATH

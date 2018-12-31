#!/bin/bash
cd ~/raspberry_pi
git status | grep modified >/dev/null
LC=$?
if [ $LC -eq 0 ]; then
    git stash 
    git reset --hard HEAD
fi
git pull
if [ $LC -eq 0 ]; then
    git stash pop
fi

~/raspberry_pi/scripts/post_update_setup.sh

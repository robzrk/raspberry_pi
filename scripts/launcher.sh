#!/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts

$SCRIPTS_DIR/update_repo.sh

sleep 5

$SCRIPTS_DIR/read_email.py

lxterminal -e $SCRIPTS_DIR/pi_ui.sh

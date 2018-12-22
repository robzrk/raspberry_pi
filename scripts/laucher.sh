#!/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts
$SCRIPTS_DIR/read_email.py
terminator --geometry=320x480 -e $SCRIPTS_DIR/pi_ui.sh

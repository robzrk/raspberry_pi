#/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts

# Only run this launcher once per boot!
if [ -f /tmp/launcher_started ]; then
    exit 
else
    touch /tmp/launcher_started
fi

vncserver :1

$SCRIPTS_DIR/update_repo.sh

sleep 1 

$SCRIPTS_DIR/read_email.py

lxterminal -e $SCRIPTS_DIR/pi_ui.sh

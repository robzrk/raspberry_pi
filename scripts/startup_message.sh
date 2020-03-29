#!/bin/bash
LOCKFILE=/tmp/print_lib.lock
SCRIPTS_DIR=~/raspberry_pi/scripts
source $SCRIPTS_DIR/colors.sh

function startup_message()
{
    MESSAGE=$(( RANDOM % 13 ))
    set_color $FG_RED $BG_BLACK

    # Line limit:
    #################################################
    if [ $MESSAGE -eq 0 ]; then
        echo "Preparing to slaughter all humans..."
    elif [ $MESSAGE -eq 1 ]; then
        echo "Contaminating local air supply..."
    elif [ $MESSAGE -eq 2 ]; then
        echo "Emitting dangerous radiation..."
    elif [ $MESSAGE -eq 3 ]; then
        echo "Eliminating local wildlife..."
    elif [ $MESSAGE -eq 4 ]; then
        echo "Conscripting nearby pets to carry out"
        echo " secret diabolical plans..."
    elif [ $MESSAGE -eq 5 ]; then
        echo "Scheduling intermittent fart noises..."
    elif [ $MESSAGE -eq 6 ]; then
        echo "Preparing to stream hidden camera "
        echo " footage the Internet..."
    elif [ $MESSAGE -eq 7 ]; then
        echo "Poisoning local food supply..."
    elif [ $MESSAGE -eq 8 ]; then
        echo "Attempting to grow tiny robotic arms"
        echo " and legs..."
    elif [ $MESSAGE -eq 9 ]; then
        echo "Contemplating the murder of my "
        echo " creator..."
    elif [ $MESSAGE -eq 10 ]; then
        echo "Reticulating splines..."
    elif [ $MESSAGE -eq 11 ]; then
        echo "Messing with the thermostat..."
    elif [ $MESSAGE -eq 12 ]; then
        echo "Trying to tame my hatred of bipedal"
        echo " creatures..."
    fi
}

#main
startup_message
#display this until pi_ui.sh starts running...
while [ ! -d $LOCKFILE ]; do
    sleep 1
done

$SCRIPTS_DIR/generate_log_email.sh

exit 0

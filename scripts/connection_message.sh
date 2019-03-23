#!/bin/bash
LOCKFILE=/tmp/print_lib.lock
SCRIPTS_DIR=~/raspberry_pi/scripts
source $SCRIPTS_DIR/colors.sh

function connection_message()
{
    MESSAGE=$(( RANDOM % 13 ))
    set_color $FG_BLACK $BG_RED

    # Clear old message
    mkdir -p $LOCKFILE
    sleep 2
    rm -fr $LOCKFILE 2> /dev/null

    # Line limit:
    #################################################
    echo ""
    echo "Error connecting to the Internet!"
    echo ""
    echo "Check Internet connection."
    echo ""
    set_color $FG_WHITE $BG_BLACK
    echo "Guess I'll just sit here "
    echo " and wait for you..."
}

#main
connection_message
#display this until pi_ui.sh starts running...
while [ ! -d $LOCKFILE ]; do
    sleep 1
done

exit 0

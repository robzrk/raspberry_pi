#!/bin/bash
LOCKFILE=/tmp/print_lib.lock
PRINT_LOCK_TO=10
LOG_PATH=/tmp/pi_ui.log

function log() {
    local LOG_MSG=$1
    echo "`date`: $LOG_MSG" >> $LOG_PATH
}

function acquire_print_lock() {
    TIMER_START=$SECONDS
    while [ 1 ]; do
    	mkdir $LOCKFILE 2> /dev/null
    	if [ $? -eq 0 ]; then
    	    break
    	fi
        DURATION=$(( SECONDS - TIMER_START ))
        if [ $DURATION -gt $PRINT_LOCK_TO ]; then
            log "WARNING: Timed out waiting for print lock!"
            release_print_lock
            # we'll acquire it on the next iteration.
        fi
    done
}

function release_print_lock() {
    rm -fr $LOCKFILE
}

function print_lock() {
    while [ 1 ]; do
    	mkdir $LOCKFILE 2> /dev/null
    	if [ $? -eq 0 ]; then
    	    break
    	fi
    done
    echo $1 "$2"
    rm -fr $LOCKFILE
}
    
function print_lock_cleanup() {
    rm -fr $LOCKFILE
}

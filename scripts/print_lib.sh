#!/bin/bash
LOCKFILE=/tmp/print_lib.lock

function print_lock() {
    # while [ 1 ]; do
    # 	mkdir $LOCKFILE 2> /dev/null
    # 	if [ $? -eq 0 ]; then
    # 	    break
    # 	fi
    # done
    echo $1 "$2"
    # rm -fr $LOCKFILE
}
    
function print_lock_cleanup() {
    rm -fr $LOCKFILE
}

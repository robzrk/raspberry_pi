#!/bin/bash
COUNT=0


function run_pass() {
    echo -ne "\rHello! $COUNT"
    COUNT=$(( COUNT + 1 ))
    sleep 1
}

function run_loop() {
    while [ 1 ]; do
	run_pass
    done
}

################################################################################
## Main
################################################################################

run_loop

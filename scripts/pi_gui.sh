#!/bin/bash
COUNT=0
SCRIPTS_DIR=~/raspberry_pi/scripts

source $SCRIPTS_DIR/colors.sh
source $SCRIPTS_DIR/cursor_manipulation.sh

trap ctrl_c INT

function ctrl_c() {
    fg_default
    cm_move_cursor_to_point $LINES 0
    exit 0
}

function run_pass() {
    update_weather
    dump_basic_weather
    for i in {1..5}; do
	dump_date
	spin_one_second
    done
}

function clear_specified_line_keep_border() {
    local L=$1
    fg_purple
    cm_clear_specified_line $L 0
    cm_move_cursor_to_point $L 0
    echo -n "*"
    cm_move_cursor_to_point $L $COLUMNS
    echo -n "*"
}

function draw_border() {
    fg_purple
    cm_move_cursor_to_point 0 0
    cm_clear_screen
    LINE=1
    while [ $LINE -lt $LINES ]; do
	if [ $LINE -eq 1 -o $LINE -eq $((LINES-1)) ]; then
	    COL=1
	    while [ $COL -le $COLUMNS ]; do
	    	echo -n "*"
		COL=$(( COL + 1 ))
	    done
	else
	    echo -n "*"
	    cm_move_cursor_to_point $LINE $COLUMNS
	    echo -n "*"
	fi
	echo ""
	LINE=$(( LINE + 1 ))
    done
}

function spin_one_second() {
    cm_move_cursor_to_point $((LINES-3)) $((COLUMNS-3))
    fg_blue
    local SLEEP_DUR=0.125
    for j in {1..2}; do
	echo -ne "\b-"
	sleep $SLEEP_DUR
	echo -ne "\b\\"
	sleep $SLEEP_DUR
	echo -ne "\b|"
	sleep $SLEEP_DUR
	echo -ne "\b/"
	sleep $SLEEP_DUR
    done
}

function extract_xml_data() {
    local XML=$1
    local TAG=$2
    echo "$XML" | grep "<$TAG>" | sed "s/.*<$TAG>\(.*\)<\/$TAG>.*/\1/"
}

function update_weather() {
    WEATHER=`curl http://w1.weather.gov/xml/current_obs/KMSP.xml 2>/dev/null`
}

function dump_basic_weather() {
    TEMP=`extract_xml_data "$WEATHER" temp_f`
    STRING=`extract_xml_data "$WEATHER" weather`
    WIND_DIR=`extract_xml_data "$WEATHER" wind_dir`
    WIND_MPH=`extract_xml_data "$WEATHER" wind_mph`
    HUMIDITY=`extract_xml_data "$WEATHER" relative_humidity`
    clear_specified_line_keep_border 2
    cm_move_cursor_to_point 2 3
    fg_random
    echo -n "$STRING. "
    fg_random
    echo -n "${TEMP}ºF. "
    fg_random
    echo -n "Wind: $WIND_DIR @ ${WIND_MPH}MPH "
    fg_random
    echo "Humidity: ${HUMIDITY}%"
}

function dump_date() {
    DATE=`date`
    clear_specified_line_keep_border $((LINES-3))
    cm_move_cursor_to_point $((LINES-3)) 3
    fg_cyan
    echo -n "$DATE"
}

function run_loop() {
    draw_border
    while [ 1 ]; do
    	run_pass
    done
}

################################################################################
## Main
################################################################################

run_loop

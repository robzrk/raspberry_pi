#!/bin/bash

#DEBUG
#set -x

SCRIPTS_DIR=~/raspberry_pi/scripts
source $SCRIPTS_DIR/colors.sh
source $SCRIPTS_DIR/cursor_manipulation.sh

trap ctrl_c INT

# Emacs terminal
# function get_height() {
#     echo $LINES
# }
# function get_width() {
#     echo $COLUMNS
# }
function get_height() {
    # tput lines
    echo 19
}
function get_width() {
    # tput cols
    echo 58
}

function ctrl_c() {
    fg_default
    cm_move_cursor_to_point $HEIGHT 0
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
    fg_light_purple
    cm_clear_specified_line $L 0
    cm_move_cursor_to_point $L 0
    echo -n "*"
    cm_move_cursor_to_point $L $WIDTH
    echo -n "*"
}

function draw_border() {
    fg_light_purple
    cm_move_cursor_to_point 0 0
    cm_clear_screen
    local LINE=1
    while [ $LINE -lt $HEIGHT ]; do
	if [ $LINE -eq 1 -o $LINE -eq $((HEIGHT-1)) ]; then
	    local COL=1
	    while [ $COL -le $WIDTH ]; do
	    	echo -n "*"
		COL=$(( COL + 1 ))
	    done
	else
	    echo -n "*"
	    cm_move_cursor_to_point $LINE $WIDTH
	    echo -n "*"
	fi
	echo ""
	LINE=$(( LINE + 1 ))
    done
}

function spin_one_second() {
    cm_move_cursor_to_point $((HEIGHT-3)) $((WIDTH-3))
    fg_yellow
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
    local TEMP=`extract_xml_data "$WEATHER" temp_f`
    local STRING=`extract_xml_data "$WEATHER" weather`
    local WIND_DIR=`extract_xml_data "$WEATHER" wind_dir`
    local WIND_MPH=`extract_xml_data "$WEATHER" wind_mph`
    local HUMIDITY=`extract_xml_data "$WEATHER" relative_humidity`
    local DISPLAY_LINE=2
    local DISPLAY_COL=3
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    fg_random
    echo -n "$STRING."
    DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    fg_random
    echo -n "${TEMP}ºF."
    DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    fg_random
    echo -n "Wind: $WIND_DIR @ ${WIND_MPH}MPH"
    DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    fg_random
    echo -n "Humidity: ${HUMIDITY}%"
}

function dump_date() {
    local DATE=`TZ='America/Chicago' date +"%A %b %d %l:%M:%S"`
    clear_specified_line_keep_border $((HEIGHT-3))
    cm_move_cursor_to_point $((HEIGHT-3)) 3
    fg_cyan
    echo -n "$DATE"
}

function run_loop() {
    draw_border
    while [ 1 ]; do
    	run_pass
    done
}

# Globals
COUNT=0
HEIGHT=`get_height`
WIDTH=`get_width`

################################################################################
## Main
################################################################################

run_loop

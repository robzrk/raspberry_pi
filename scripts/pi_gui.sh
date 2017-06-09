#!/bin/bash
COUNT=0
SCRIPTS_DIR=~/raspberry_pi/scripts

source $SCRIPTS_DIR/colors.sh

function run_pass() {
    update_weather
    clear
    dump_basic_weather
    countdown_to_next_iter
}

function countdown_to_next_iter() {
    fg_random
    local SLEEP_DUR=0.2
    for i in {1..5}; do
	echo -ne "\r-"
	sleep $SLEEP_DUR
	echo -ne "\r\\"
	sleep $SLEEP_DUR
	echo -ne "\r|"
	sleep $SLEEP_DUR
	echo -ne "\r/"
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
    fg_random
    echo -n "$STRING. "
    fg_random
    echo -n "${TEMP}ºF. "
    fg_random
    echo -n "Wind: $WIND_DIR @ ${WIND_MPH}MPH "
    fg_random
    echo "Humidity: ${HUMIDITY}%"
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

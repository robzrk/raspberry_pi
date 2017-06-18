#!/bin/bash

#DEBUG
#set -x

SCRIPTS_DIR=~/raspberry_pi/scripts
source $SCRIPTS_DIR/cursor_manipulation.sh
source $SCRIPTS_DIR/colors.sh
source $SCRIPTS_DIR/numbers.sh

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
#     echo 19
    echo 30
}
function get_width() {
    # tput cols
#     echo 58
    echo 36
}

function ctrl_c() {
    fg_default
    cm_move_cursor_to_point $HEIGHT 0
    exit 0
}

function run_pass_blocking() {
    dump_basic_weather
    # dump_basic_forecast
    # exit 0
   for i in {1..15}; do
	dump_date
	spin_one_second
   done
}

function run_pass_non_blocking() {
    local OFFSET=0
    for i in {1..15}; do
	draw_weather $OFFSET
	cm_move_cursor_to_point $((HEIGHT-3)) $((WIDTH-3))
	#OFFSET=$((OFFSET+1))
	sleep 1
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

function extract_xml_weather() {
    local XML=$1
    local TAG=$2
    echo "$XML" | grep "<$TAG>" | sed "s/.*<$TAG>\(.*\)<\/$TAG>.*/\1/"
}

function extract_xml_forecast() {
    local XML=$1
    local TAG=$2
    local FIELD=$3
    local TOKENIZED_XML=`echo $XML | sed "s/${TAG}/_/g"`
    (
	IFS='_'; 
	for TOK in $TOKENIZED_XML; do
	    echo "$TOK" | sed "s/.*${FIELD}=\"\(.*\)\".*/\1/"
	done
    )
}

function update_weather() {
    WEATHER=`curl http://w1.weather.gov/xml/current_obs/KMSP.xml 2>/dev/null`
    # echo $WEATHER > weather.xml
    # WEATHER=`cat weather.xml`
    # FORECAST=`curl "http://api.openweathermap.org/data/2.5/forecast?id=5037649&mode=xml&APPID=94bd78ff32b4f3ff159847bc6f2d744a" 2>/dev/null`
    # echo $FORECAST > forecast.xml
    # FORECAST=`cat forecast.xml`
}

function dump_basic_weather() {
    local TEMP=`extract_xml_weather "$WEATHER" temp_f`
    #TEMP=`echo $TEMP | sed "s/\([0-9]*\).*/\1/g"`
    local STRING=`extract_xml_weather "$WEATHER" weather`
    local WIND_DIR=`extract_xml_weather "$WEATHER" wind_dir`
    local WIND_MPH=`extract_xml_weather "$WEATHER" wind_mph`
    local HUMIDITY=`extract_xml_weather "$WEATHER" relative_humidity`

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
    echo -n "Wind: $WIND_DIR @ ${WIND_MPH}MPH"
    DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    fg_random
    echo -n "Humidity: ${HUMIDITY}%"
    DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    fg_random
    echo -n "${TEMP}ºF"
    DISPLAY_LINE=$((DISPLAY_LINE+8))
    DISPLAY_COL=$((DISPLAY_COL+1))
    fg_random
    print_large_number $TEMP $DISPLAY_LINE $DISPLAY_COL
}

function draw_weather() {
    local OFFSET=$1
    local STRING=`extract_xml_weather "$WEATHER" weather`

    local DISPLAY_LINE=9
    local DISPLAY_COL=$((OFFSET + 3))
    draw_weather_aux "$STRING" $DISPLAY_LINE $DISPLAY_COL
}

function draw_weather_aux() {
    local WEATHER_STRING=$1
    local DISPLAY_LINE=$2
    local DISPLAY_COL=$3

    local CURR_HOUR=`TZ='America/Chicago' date +"%H"`
    if [ $CURR_HOUR -gt 6 -o $CURR_HOUR -lt 20 ]; then
	local IS_DAYTIME=1
    else
	local IS_DAYTIME=0
    fi

    local LINE0="                                "
    local LINE1="                                "
    local LINE2="                                "
    local LINE3="                                "
    local LINE4="                                "
    local LINE5="                                "
    if [[ $WEATHER_STRING == *"Cloud"* ]]; then
	fg_white
	LINE0="      _____              ______ "
	LINE1="     (_____) __    ___  (______)"
	LINE2="            (__)  (___)         "
	LINE3="                __              "
	LINE4="   ______      (__)         _   "
	LINE5="  (______)                 (_)  "
    elif [[ $WEATHER_STRING == *"Overcast"* ]]; then
	fg_light_gray
	LINE0="_       _            -    _    -"
	LINE1="-   -           -              -"  
	LINE2="_--__-----_---_____-_---____----"
	LINE3="                                "
	LINE4="                                "
	LINE5="                                "
    elif [[ $WEATHER_STRING == *"Fair"* && $IS_DAYTIME -eq 0 ]]; then
	fg_white
	LINE0="            *        *    *     "
	LINE1="  *            *      *        *"
	LINE2="      *                  *      "
	LINE3="          *         *           "
	LINE4="    *                        *  "
	LINE5="                 *     *        "
    elif [[ $WEATHER_STRING == *"Fair"* && $IS_DAYTIME -eq 1 ]]; then
	fg_yellow
	LINE0="         \   __|__   /          "
	LINE1="        -   /     \   -         "
	LINE2="       _   /       \   _        "
	LINE3="       _   \       /   _        "
	LINE4="        -   \_____/   -         "
	LINE5="         /     |     \          "
    elif [[ $WEATHER_STRING == *"Rain"* ]]; then
	fg_light_blue
	LINE0="_--__-----_---_____-_---____---_"
	LINE1="  \    \       \           \  \ "
	LINE2=" \   \     \   \   \ \   \      "
	LINE3="    \ \      \                \ "
	LINE4="         \       \    \      \  "
	LINE5="  \   \       \      \    \   \ "
    elif [[ $WEATHER_STRING == *"Thunderstorm"* ]]; then
	fg_yellow
	LINE0="          |\           \        "
	LINE1="    \     \ \          \\       "
	LINE2="    \\    _\ \         //       "
	LINE3="    //    \  _\        \\       "
	LINE4="    \\     \ \          \       "
	LINE5="     \      \|                  "
    elif [[ $WEATHER_STRING == *"Fog"* ]]; then
	fg_light_gray
	LINE0="################################"
	LINE1="################################"
	LINE2="################################"
	LINE3="################################"
	LINE4="################################"
	LINE5="################################"
    fi

    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    echo -n "$LINE0"
    cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
    echo -n "$LINE1"
    cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
    echo -n "$LINE2"
    cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
    echo -n "$LINE3"
    cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
    echo -n "$LINE4"
    cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
    echo -n "$LINE5"
}

function dump_basic_forecast() {
    local TEMP=`extract_xml_forecast "$FORECAST" time from`
    local DISPLAY_LINE=2
    local DISPLAY_COL=3
    # clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    # fg_random
    echo -n "${TEMP}"
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
    xdotool mousemove 0 0
    while [ 1 ]; do
	update_weather
    	run_pass_non_blocking &
    	run_pass_blocking
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

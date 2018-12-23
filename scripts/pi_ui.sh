#!/bin/bash

#DEBUG
#set -x

SCRIPTS_DIR=~/raspberry_pi/scripts
source $SCRIPTS_DIR/cursor_manipulation.sh
source $SCRIPTS_DIR/colors.sh
source $SCRIPTS_DIR/numbers.sh
source $SCRIPTS_DIR/print_lib.sh

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
    echo 37
}

function ctrl_c() {
    kill -9 $DDT_PID
    print_lock_cleanup
    fg_default
    bg_default
    print_lock_cleanup
    cm_move_cursor_to_point $HEIGHT 0
    print_lock_cleanup
    exit 0
}

# This function can only be called when lock is already held
function clear_specified_line_keep_border() {
    local L=$1
    fg_light_purple
    bg_default
    cm_clear_specified_line $L 0
    cm_move_cursor_to_point $L 0
    echo -n "*"
    cm_move_cursor_to_point $L $WIDTH
    echo -n "*"
}

function draw_border() {
    acquire_print_lock
    fg_light_purple
    bg_default
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
    release_print_lock
}

function spin_one_second() {
    local STAGE=$1
    acquire_print_lock
    fg_yellow
    cm_move_cursor_to_point $((HEIGHT-3)) $((WIDTH-2))
    case $STAGE in
    0)
        echo -ne "\b-"
        ;;
    1)
        echo -ne "\b\\"
        ;;
    2)
        echo -ne "\b|"
        ;;
    3)
        echo -ne "\b/"
        ;;
    esac
    release_print_lock
    sleep 1
}

function extract_xml_value() {
    local XML=$1
    local TAG=$2
    echo "$XML" | grep "<$TAG>" | sed "s/.*<$TAG>\(.*\)<\/$TAG>.*/\1/"
}

function extract_json_value() {
    local JSON=$1
    local NAME=$2
    echo "$JSON" | grep "\"$NAME\":" | sed "s/.*\"${NAME}\":\"\([^,]*\)\".*/\1/"
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
    WEATHER=`curl -s https://w1.weather.gov/xml/current_obs/KMSP.xml`
    return $?
    # echo $WEATHER > weather.xml
    # WEATHER=`cat weather.xml`
    # FORECAST=`curl "http://api.openweathermap.org/data/2.5/forecast?id=5037649&mode=xml&APPID=94bd78ff32b4f3ff159847bc6f2d744a" 2>/dev/null`
    # echo $FORECAST > forecast.xml
    # FORECAST=`cat forecast.xml`
}

function update_sunset() {
    SUNSET=`curl -s https://api.sunrise-sunset.org/json?lat=44.97\&lng=-93.25&date=today`
    return $?
}

function dump_basic_weather() {
    local TEMP=`extract_xml_value "$WEATHER" temp_f`
    local TEMP=`echo $TEMP | sed "s/\([0-9]*\).*/\1/g"`
    local STRING=`extract_xml_value "$WEATHER" weather`
    local WIND_DIR=`extract_xml_value "$WEATHER" wind_dir`
    local WIND_MPH=`extract_xml_value "$WEATHER" wind_mph`
    local HUMIDITY=`extract_xml_value "$WEATHER" relative_humidity`
    local WINDCHILL=`extract_xml_value "$WEATHER" windchill_f`
    local WINDCHILL=`echo $WINDCHILL | sed "s/\([0-9]*\).*/\1/g"`
    local COLOR_TEMP=$TEMP
    if [[ ( "$WINDCHILL" != "$TEMP" ) && ( "$WINDCHILL" != "" ) ]]; then
    local COLOR_TEMP=$WINDCHILL
    fi

    local DISPLAY_LINE=2
    local DISPLAY_COL=3
    acquire_print_lock
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    bg_default
    fg_color_from_temp $COLOR_TEMP
    echo -n "$STRING."
    local DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    bg_default
    fg_color_from_temp $COLOR_TEMP
    echo -n "Wind: $WIND_DIR @ ${WIND_MPH}MPH"
    local DISPLAY_LINE=$((DISPLAY_LINE+2))
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    bg_default
    fg_color_from_temp $COLOR_TEMP
    echo -n "Humidity: ${HUMIDITY}%"
    local DISPLAY_LINE=$((DISPLAY_LINE+12))
    if [ $TEMP -ge 100 ]; then
    local DISPLAY_COL=5
    else
    local DISPLAY_COL=10
    fi
    bg_default
    fg_color_from_temp $COLOR_TEMP
    print_large_number $TEMP $DISPLAY_LINE $DISPLAY_COL
    if [[ ( "$WINDCHILL" != "$TEMP" ) && ( "$WINDCHILL" != "" ) ]]; then
    local DISPLAY_LINE=$((DISPLAY_LINE+8))
    local DISPLAY_COL=12
    clear_specified_line_keep_border $DISPLAY_LINE
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    bg_default
    fg_color_from_temp $COLOR_TEMP
    echo -n "${WINDCHILL}ºF windchill"
    fi
    release_print_lock
}

function fg_color_from_temp()
{
    local TEMP=$1
    if [ $TEMP -ge 110 ]; then
    fg_light_red
    elif [ $TEMP -ge 100 ]; then
    fg_red
    elif [ $TEMP -ge 90 ]; then
    fg_brown
    elif [ $TEMP -ge 80 ]; then
    fg_yellow
    elif [ $TEMP -ge 70 ]; then
    fg_light_green
    elif [ $TEMP -ge 60 ]; then
    fg_green
    elif [ $TEMP -ge 50 ]; then
    fg_light_cyan
    elif [ $TEMP -ge 40 ]; then
    fg_cyan
    elif [ $TEMP -ge 30 ]; then
    fg_light_blue
    elif [ $TEMP -ge 20 ]; then
    fg_blue
    elif [ $TEMP -ge 10 ]; then
    fg_white
    elif [ $TEMP -ge 0 ]; then
    fg_light_purple
    elif [ $TEMP -ge -10 ]; then
    fg_purple
    elif [ $TEMP -ge -20 ]; then
    fg_light_gray
    else
    fg_dark_gray
    fi
}

function draw_weather() {
    local STRING=`extract_xml_value "$WEATHER" weather`
    
    local DISPLAY_LINE=9
    local DISPLAY_COL=$((OFFSET + 3))
    draw_weather_aux "$STRING" $DISPLAY_LINE $DISPLAY_COL
}

function draw_weather_aux() {
    local WEATHER_STRING=$1
    local DISPLAY_LINE=$2
    local DISPLAY_COL=$3

    local SUNSET_TIME=`extract_json_value "$SUNSET" sunset`
    local SUNSET_TIME_FMT=`echo $SUNSET_TIME | sed "s/://g" | head -c 4`
    SUNSET_TIME_FMT=$(( SUNSET_TIME_FMT + 1200 ))
    SUNSET_TIME_FMT=`echo ${SUNSET_TIME_FMT:0:2}:${SUNSET_TIME_FMT:2:4}`
    local SUNSET_TIME_CMP=`env TZ='America/Chicago' date -d "$SUNSET_TIME_FMT UTC" +"%H%M"`
    local CURR_TIME=`TZ='America/Chicago' date +"%H%M"`
    if [ $CURR_TIME -le $SUNSET_TIME_CMP ]; then
    local IS_DAYTIME=1
    else
    local IS_DAYTIME=0
    fi
    
    if [[ $WEATHER_STRING == *"Cloud"* ]]; then
    draw_clouds
    elif [[ $WEATHER_STRING == *"Overcast"* ]]; then
    draw_overcast
    elif [[ $WEATHER_STRING == *"Snow"* ]]; then
    draw_snow
    elif [[ $WEATHER_STRING == *"Fair"* && $IS_DAYTIME -eq 0 ]]; then
    draw_clear
    elif [[ $WEATHER_STRING == *"Fair"* && $IS_DAYTIME -eq 1 ]]; then
    draw_sunny
    elif [[ $WEATHER_STRING == *"Rain"* ]]; then
    draw_rain
    elif [[ $WEATHER_STRING == *"Thunderstorm"* ]]; then
    draw_thunderstorm
    elif [[ $WEATHER_STRING == *"Fog"* ]]; then
    draw_fog
    fi
}

function dump_basic_forecast() {
    local TEMP=`extract_xml_forecast "$FORECAST" time from`
    local DISPLAY_LINE=2
    local DISPLAY_COL=3
    acquire_print_lock
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    release_print_lock
    print_lock "-n" "${TEMP}"
}

function start_daily_text_display() {
    display_daily_text &
    DDT_PID=$!
}

function display_daily_text() {
    local OFFSET=0
    local DISPLAY_LINE=28
    local DISPLAY_COL=3
    local LWID=$((WIDTH-5))
    local MESSAGE_IN=`cat $SCRIPTS_DIR/daily_text | tr -d '\r' | tr -d '\n'`
    MESSAGE="${MESSAGE_IN}     "
    local MSG_LEN=${#MESSAGE}
    while [ 1 ]; do
    scroll_message $OFFSET $DISPLAY_LINE $DISPLAY_COL $LWID
    sleep .1
    local OFFSET=$((OFFSET+1))
    if [ $OFFSET -gt $MSG_LEN ]; then
        local OFFSET=0
    fi
    done
}

function dump_date() {
    local DATE=`TZ='America/Chicago' date +"%A %b %d %l:%M:%S"`
    acquire_print_lock
    clear_specified_line_keep_border $((HEIGHT-3))
    cm_move_cursor_to_point $((HEIGHT-3)) 3
    fg_cyan
    bg_default
    echo -n "$DATE"
    release_print_lock
}

function kill_pid_and_refresh() {
    local KILL_PID=$1
    kill -9 $KILL_PID
    echo "" # force the kill printout to happen
    usleep 5000
    clear
    draw_border
}

function run_loop() {
    # Ensure lock is release from previous runs
    release_print_lock

    draw_border
    xdotool mousemove 0 0
    start_daily_text_display
    local CURRENT_WEATHER_STRING=""
    local PREVIOUS_WEATHER_STRING=""
    local RPNB_PID=0
    local DE_PID=0
    local RUN_CNT=0
    while [ 1 ]; do
    # Hack - do this until echo statements between threads can run cleanly
    if [ $RUN_CNT -eq 0 ]; then
        clear
        draw_border
        $SCRIPTS_DIR/check_email.py
        if [ $? -eq 0 ]; then
            $SCRIPTS_DIR/read_email.py
            kill_pid_and_refresh $DDT_PID
            start_daily_text_display
            pcmanfm --set-wallpaper $SCRIPTS_DIR/daily_photo
        fi
    fi

    # Update the weather, but display a connection error if there is one
    if [ $DE_PID -ne 0 ]; then
        kill_pid_and_refresh $DE_PID
    fi
    update_weather
    if [ $? -ne 0 ]; then
        kill_pid_and_refresh $RPNB_PID
        draw_error &
        DE_PID=$!
        sleep 3
        continue
    else
        DE_PID=0
    fi
    update_sunset

    CURRENT_WEATHER_STRING=`extract_xml_value "$WEATHER" weather`
    if [ "$CURRENT_WEATHER_STRING" != "$PREVIOUS_WEATHER_STRING" ]; then
        if [ $RPNB_PID -ne 0 ]; then
            kill_pid_and_refresh $RPNB_PID
        fi
        run_pass_non_blocking &
        RPNB_PID=$!
    fi
    run_pass_blocking
    PREVIOUS_WEATHER_STRING=$CURRENT_WEATHER_STRING
    RUN_CNT=$(((RUN_CNT+1)%10))
    done
}


function run_pass_blocking() {
    dump_basic_weather
    # dump_basic_forecast
    # exit 0
    for i in {1..15}; do
    dump_date
    sleep 1
    done
}

function run_pass_non_blocking() {
    draw_weather
}

################################################################################
# Draw functions
################################################################################

function draw_error() {
    LINE0="                                "
    LINE1="                                "
    LINE2=" Connection Error.              "
    LINE3="                                "
    LINE4="                                "
    LINE5="                                "

    local OFFSET=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    local LWID=$((WIDTH-5))
    while [ 1 ]; do
    scroll_image $OFFSET $DISPLAY_LINE $DISPLAY_COL $LWID fg_light_gray bg_default
    sleep 1
    local OFFSET=$((OFFSET+1))
    if [ $OFFSET -gt $LWID ]; then
        local OFFSET=0
    fi
    done
}

function draw_clouds() {
    LINE0="      _____              ______ "
    LINE1="     (_____) __    ___  (______)"
    LINE2="            (__)  (___)         "
    LINE3="                __              "
    LINE4="   ______      (__)         _   "
    LINE5="  (______)                 (_)  "

    local OFFSET=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    local LWID=$((WIDTH-5))
    while [ 1 ]; do
    scroll_image $OFFSET $DISPLAY_LINE $DISPLAY_COL $LWID fg_white bg_default
    sleep 1
    local OFFSET=$((OFFSET+1))
    if [ $OFFSET -gt $LWID ]; then
        local OFFSET=0
    fi
    done
}

function draw_overcast() {
    LINE0="  -     _            -    _    -"
    LINE1="-   -           -           _   "  
    LINE2="_--__-----_---_____-_---____----"
    LINE3="                                "
    LINE4="                                "
    LINE5="                                "

    local OFFSET=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    local LWID=$((WIDTH-5))
    while [ 1 ]; do
    scroll_image $OFFSET $DISPLAY_LINE $DISPLAY_COL $LWID fg_light_gray bg_default
    sleep 1
    local OFFSET=$((OFFSET+1))
    if [ $OFFSET -gt $LWID ]; then
        local OFFSET=0
    fi
    done
}

function draw_sunny() {
    LINE0_0="             _____              "
    LINE1_0="            /     \             "
    LINE2_0="           /       \            "
    LINE3_0="           \       /            "
    LINE4_0="            \_____/             "
    LINE5_0="                                "

    LINE0_1="             __.__              "
    LINE1_1="           ./     \.            "
    LINE2_1="          ./       \.           "
    LINE3_1="          .\       /.           "
    LINE4_1="           .\__.__/.            "
    LINE5_1="                                "

    LINE0_2="             __|__              "
    LINE1_2="           \/     \/            "
    LINE2_2="          _/       \_           "
    LINE3_2="          _\       /_           "
    LINE4_2="           /\_____/\            "
    LINE5_2="               |                "

    LINE0_3="          \  __'__  /           "
    LINE1_3="            /     \             "
    LINE2_3="         _ /       \ _          "
    LINE3_3="         _ \       / _          "
    LINE4_3="            \_____/             "
    LINE5_3="          /    |    \           "

    LINE0_4="          '  _____  '           "
    LINE1_4="            / .   \             "
    LINE2_4="       _   /       \   _        "
    LINE3_4="       _   \       /   _        "
    LINE4_4="            \_____/             "
    LINE5_4="         .     .     .          "

    LINE0_5="             _____              "
    LINE1_5="            / . . \             "
    LINE2_5="    _      /       \      _     "
    LINE3_5="    _      \ \     /      _     "
    LINE4_5="            \_____/             "
    LINE5_5="                                "

    LINE0_6="             _____              "
    LINE1_6="            / . . \             "
    LINE2_6="_          /       \           _"
    LINE3_6="_          \ \__   /           _"
    LINE4_6="            \_____/             "
    LINE5_6="                                "
    
    LINE0_7="             _____              "
    LINE1_7="            / . . \             "
    LINE2_7="           /       \            "
    LINE3_7="           \ \___/ /            "
    LINE4_7="            \_____/             "
    LINE5_7="                                "

    
    local FRAME=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    while [ 1 ]; do
    show_frame $FRAME $DISPLAY_LINE $DISPLAY_COL fg_yellow
    sleep .3
    local FRAME=$(((FRAME+1)%8))
    done
}

function draw_rain() {
    LINE0_0="_--__-----_---_____-_---____---_"
    LINE1_0="  \   \       \      \    \   \ "
    LINE2_0="   \    \       \           \  \ "
    LINE3_0="   \   \     \   \   \ \   \    "
    LINE4_0="\      \ \      \               "
    LINE5_0="             \       \    \     "
    
    LINE0_1="_--__-----_---_____-_---____---_"
    LINE1_1="         \       \    \      \  "
    LINE2_1="   \   \       \      \    \   \ "
    LINE3_1="    \    \       \           \  "
    LINE4_1="    \   \     \   \   \ \   \   "
    LINE5_1=" \      \ \      \              "
    
    LINE0_2="_--__-----_---_____-_---____---_"
    LINE1_2="    \ \      \                \ "
    LINE2_2="          \       \    \      \ "
    LINE3_2="\   \   \       \      \    \   "
    LINE4_2="     \    \       \           \ "
    LINE5_2="     \   \     \   \   \ \   \  "
    
    LINE0_3="_--__-----_---_____-_---____---_"
    LINE1_3=" \   \     \   \   \ \   \      "
    LINE2_3="     \ \      \                \ "
    LINE3_3="           \       \    \      \ "
    LINE4_3=" \   \   \       \      \    \  "
    LINE5_3="      \    \       \           \ "
    
    LINE0_4="_--__-----_---_____-_---____---_"
    LINE1_4="  \    \       \           \  \ "
    LINE2_4="  \   \     \   \   \ \   \     "
    LINE3_4="      \ \      \                "
    LINE4_4="            \       \    \      "
    LINE5_4="  \   \   \       \      \    \ "
    
    local FRAME=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    while [ 1 ]; do
    show_frame $FRAME $DISPLAY_LINE $DISPLAY_COL fg_blue
    sleep 1
    local FRAME=$(((FRAME+1)%5))
    done
}

function draw_clear() {
    LINE0_0="            .        .          "
    LINE1_0="  .            .      .        ."
    LINE2_0="                         .      "
    LINE3_0="          .                     "
    LINE4_0="    .                           "
    LINE5_0="                 .     .        "

    LINE0_1="            .             .     "
    LINE1_1="  .            .      .        ."
    LINE2_1="      .                  .      "
    LINE3_1="          .                     "
    LINE4_1="                             .  "
    LINE5_1="                 .     .        "

    LINE0_2="            .             .     "
    LINE1_2="                      .        ."
    LINE2_2="      .                         "
    LINE3_2="          .         .           "
    LINE4_2="    .                        .  "
    LINE5_2="                       .        "

    LINE0_3="            .             .     "
    LINE1_3="  .            .      .         "
    LINE2_3="      .                  .      "
    LINE3_3="          .         .           "
    LINE4_3="    .                        .  "
    LINE5_3="                 .              "

    LINE0_4="            .        .    .     "
    LINE1_4="  .            .               ."
    LINE2_4="                         .      "
    LINE3_4="          .         .           "
    LINE4_4="    .                        .  "
    LINE5_4="                       .        "

    LINE0_5="                          .     "
    LINE1_5="  .            .      .        ."
    LINE2_5="      .                  .      "
    LINE3_5="                                "
    LINE4_5="    .                        .  "
    LINE5_5="                 .     .        "

    local FRAME=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    while [ 1 ]; do
    show_frame $FRAME $DISPLAY_LINE $DISPLAY_COL fg_white
    sleep 4
    local FRAME=$((RANDOM % 6))
    done
}

function draw_snow() {
    LINE0_0="_--__-----_---_____-_---____---_"
    LINE1_0="  *   *       *      *    *   * "
    LINE2_0="  *    *       *           *  * "
    LINE3_0=" *   *     *   *   * *   *      "
    LINE4_0="    * *      *                * "
    LINE5_0="         *       *    *      *  "
    
    LINE0_1="_--__-----_---_____-_---____---_"
    LINE1_1="         *       *    *      *  "
    LINE2_1="  *   *       *      *    *   * "
    LINE3_1="  *    *       *           *  * "
    LINE4_1=" *   *     *   *   * *   *      "
    LINE5_1="    * *      *                * "
    
    LINE0_2="_--__-----_---_____-_---____---_"
    LINE1_2="    * *      *                * "
    LINE2_2="         *       *    *      *  "
    LINE3_2="  *   *       *      *    *   * "
    LINE4_2="  *    *       *           *  * "
    LINE5_2=" *   *     *   *   * *   *      "
    
    LINE0_3="_--__-----_---_____-_---____---_"
    LINE1_3=" *   *     *   *   * *   *      "
    LINE2_3="    * *      *                * "
    LINE3_3="         *       *    *      *  "
    LINE4_3="  *   *       *      *    *   * "
    LINE5_3="  *    *       *           *  * "
    
    LINE0_4="_--__-----_---_____-_---____---_"
    LINE1_4="  *    *       *           *  * "
    LINE2_4=" *   *     *   *   * *   *      "
    LINE3_4="    * *      *                * "
    LINE4_4="         *       *    *      *  "
    LINE5_4="  *   *       *      *    *   * "
    
    local FRAME=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    while [ 1 ]; do
    show_frame $FRAME $DISPLAY_LINE $DISPLAY_COL fg_white
    sleep 1
    local FRAME=$(((FRAME+1)%5))
    done
}

function draw_thunderstorm() {
    LINE0_0="                                "
    LINE1_0="                                "
    LINE2_0="                                "
    LINE3_0="                                "
    LINE4_0="                                "
    LINE5_0="                                "
    
    LINE0_1="\\ "
    LINE1_1="\\\\ "
    LINE2_1=" \\\\ "
    LINE3_1=" // "
    LINE4_1=" \\\\ "
    LINE5_1="  \ "

    LINE0_2=" / "
    LINE1_2="// "
    LINE2_2="\\\\ "
    LINE3_2=" \\\\ "
    LINE4_2=" // "
    LINE5_2=" / "

    LINE0_3=""
    LINE1_3=""
    LINE2_3=""
    LINE3_3=""
    LINE4_3=""
    LINE5_3=""

    local FRAME=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    local OFFSET=0
    local LWID=$((WIDTH-7))
    while [ 1 ]; do
    show_frame $FRAME $DISPLAY_LINE $((DISPLAY_COL+OFFSET)) fg_yellow
    sleep 0.2
    local FRAME=$((RANDOM % 20))
    local OFFSET=$((RANDOM % LWID))
    if [ $FRAME -gt 3 ]; then
        local FRAME=0;
    fi
    if [ $FRAME -eq 0 ]; then
        local OFFSET=0
    fi
    done
}

function draw_fog() {
    LINE0="#@#########@#################@##"
    LINE1="#################@@#######@#####"
    LINE2="#############@##################"
    LINE3="#####@##########################"
    LINE4="########################@#######"
    LINE5="@#############@###########@#####"
    
    local OFFSET=0
    local DISPLAY_LINE=7
    local DISPLAY_COL=3
    local LWID=$((WIDTH-5))
    while [ 1 ]; do
    scroll_image $OFFSET $DISPLAY_LINE $DISPLAY_COL $LWID fg_light_gray bg_default
    sleep 0.5
    local OFFSET=$((OFFSET+1))
    if [ $OFFSET -gt $LWID ]; then
        local OFFSET=0
    fi
    done
}

function scroll_message() {
    local OFFSET=$1
    local DISPLAY_LINE=$2
    local DISPLAY_COL=$3
    local LWID=$4
    local LINE_LEN=${#LINE0}

    local LLINE0_TMP=${MESSAGE:$OFFSET:$LWID}" "${MESSAGE}
    local LLINE0=${LLINE0_TMP:0:$LWID}
    
    acquire_print_lock
    bg_black
    fg_white
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    echo -n "$LLINE0"
    release_print_lock
}

function scroll_image() {
    local OFFSET=$1
    local DISPLAY_LINE=$2
    local DISPLAY_COL=$3
    local LWID=$4
    local FG_COLOR_FN=$5
    local BG_COLOR_FN=$6
    local LINE_LEN=${#LINE0}

    local LLINE0=${LINE0:$((LWID-OFFSET)):$LWID}${LINE0:0:$((LWID-OFFSET))}
    local LLINE1=${LINE1:$((LWID-OFFSET)):$LWID}${LINE1:0:$((LWID-OFFSET))}
    local LLINE2=${LINE2:$((LWID-OFFSET)):$LWID}${LINE2:0:$((LWID-OFFSET))}
    local LLINE3=${LINE3:$((LWID-OFFSET)):$LWID}${LINE3:0:$((LWID-OFFSET))}
    local LLINE4=${LINE4:$((LWID-OFFSET)):$LWID}${LINE4:0:$((LWID-OFFSET))}
    local LLINE5=${LINE5:$((LWID-OFFSET)):$LWID}${LINE5:0:$((LWID-OFFSET))}
    
    acquire_print_lock
    $FG_COLOR_FN
    $BG_COLOR_FN
    cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
    echo -n "$LLINE0"
    cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
    echo -n "$LLINE1"
    cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
    echo -n "$LLINE2"
    cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
    echo -n "$LLINE3"
    cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
    echo -n "$LLINE4"
    cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
    echo -n "$LLINE5"
    cm_move_cursor_to_point $((HEIGHT-3)) $((WIDTH-2))
    release_print_lock
}

function show_frame() {
    local FRAME=$1
    local DISPLAY_LINE=$2
    local DISPLAY_COL=$3
    local FG_COLOR_FN=$4

    acquire_print_lock
    bg_default
    $FG_COLOR_FN
    case $FRAME in
    0)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_0"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_0"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_0"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_0"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_0"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_0"
        ;;
    1)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_1"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_1"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_1"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_1"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_1"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_1"
    ;;
    2)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_2"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_2"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_2"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_2"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_2"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_2"
    ;;
    3)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_3"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_3"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_3"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_3"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_3"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_3"
    ;;
    4)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_4"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_4"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_4"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_4"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_4"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_4"
    ;;
    5)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_5"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_5"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_5"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_5"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_5"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_5"
    ;;
    6)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_6"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_6"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_6"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_6"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_6"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_6"
    ;;
    7)
        cm_move_cursor_to_point $DISPLAY_LINE $DISPLAY_COL
        echo -n "$LINE0_7"
        cm_move_cursor_to_point $((DISPLAY_LINE+1)) $DISPLAY_COL
        echo -n "$LINE1_7"
        cm_move_cursor_to_point $((DISPLAY_LINE+2)) $DISPLAY_COL
        echo -n "$LINE2_7"
        cm_move_cursor_to_point $((DISPLAY_LINE+3)) $DISPLAY_COL
        echo -n "$LINE3_7"
        cm_move_cursor_to_point $((DISPLAY_LINE+4)) $DISPLAY_COL
        echo -n "$LINE4_7"
        cm_move_cursor_to_point $((DISPLAY_LINE+5)) $DISPLAY_COL
        echo -n "$LINE5_7"
    ;;
    esac
    cm_move_cursor_to_point $((HEIGHT-3)) $((WIDTH-2))
    release_print_lock
}

# Globals
HEIGHT=`get_height`
WIDTH=`get_width`
PL=0

################################################################################
## Main
################################################################################
cm_hide_cursor
run_loop

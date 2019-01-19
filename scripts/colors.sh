#!/bin/bash
#set -x

FG_BLACK=30
FG_RED=31
FG_GREEN=32
FG_YELLOW=33
FG_BLUE=34
FG_MAGENTA=35
FG_CYAN=36
FG_WHITE=37
FG_DEFAULT=39
FG_BRIGHT_BLACK="30;1"
FG_BRIGHT_RED="31;1"
FG_BRIGHT_GREEN="32;1"
FG_BRIGHT_YELLOW="33;1"
FG_BRIGHT_BLUE="34;1"
FG_BRIGHT_MAGENTA="35;1"
FG_BRIGHT_CYAN="36;1"
FG_BRIGHT_WHITE="37;1"
BG_BLACK=40
BG_RED=41
BG_GREEN=42
BG_YELLOW=43
BG_BLUE=44
BG_MAGENTA=45
BG_CYAN=46
BG_WHITE=47
BG_BRIGHT_BLACK=100
BG_BRIGHT_RED=101
BG_BRIGHT_GREEN=102
BG_BRIGHT_YELLOW=103
BG_BRIGHT_BLUE=104
BG_BRIGHT_MAGENTA=105
BG_BRIGHT_CYAN=106
BG_BRIGHT_WHITE=107
BG_DEFAULT=49

SCRIPTS_DIR=~/raspberry_pi/scripts

function set_color() {
    local FG=$1
    local BG=$2
    echo -ne "\033[${FG};${BG}m"
}

function set_color_from_temp()
{
    local TEMP=$1
    local FG=$FG_DEFAULT
    local BG=$BG_DEFAULT
    if [ $TEMP -ge 110 ]; then
        FG=$FG_BLACK
        BG=$BG_MAGENTA
    elif [ $TEMP -ge 100 ]; then
        FG=$FG_BLACK
        BG=$BG_RED
    elif [ $TEMP -ge 90 ]; then
        FG=$FG_BLACK
        BG=$BG_YELLOW
    elif [ $TEMP -ge 80 ]; then
        FG=$FG_BLACK
        BG=$BG_GREEN
    elif [ $TEMP -ge 70 ]; then
        FG=$FG_BLACK
        BG=$BG_CYAN
    elif [ $TEMP -ge 60 ]; then
        FG=$FG_BLACK
        BG=$BG_BLUE
    elif [ $TEMP -ge 50 ]; then
        FG=$FG_BRIGHT_WHITE
        BG=$BG_BLACK
    elif [ $TEMP -ge 40 ]; then
        FG=$FG_BRIGHT_CYAN
        BG=$BG_BLACK
    elif [ $TEMP -ge 30 ]; then
        FG=$FG_BRIGHT_GREEN
        BG=$BG_BLACK
    elif [ $TEMP -ge 20 ]; then
        FG=$FG_BRIGHT_BLUE
        BG=$BG_BLACK
    elif [ $TEMP -ge 10 ]; then
        FG=$FG_BRIGHT_MAGENTA
        BG=$BG_BLACK
    elif [ $TEMP -ge 0 ]; then
        FG=$FG_BRIGHT_WHITE
        BG=$BG_BRIGHT_CYAN
    elif [ $TEMP -ge -10 ]; then
        FG=$FG_BRIGHT_WHITE
        BG=$BG_BRIGHT_GREEN
    elif [ $TEMP -ge -20 ]; then
        FG=$FG_BRIGHT_WHITE
        BG=$BG_BRIGHT_BLUE
    else
        FG=$FG_BRIGHT_WHITE
        BG=$BG_BRIGHT_MAGENTA
    fi
    set_color $FG $BG
}

function set_leds_from_temp()
{
    local TEMP=$1
    $SCRIPTS_DIR/led.py -t $TEMP
    # if [ $TEMP -ge 110 ]; then
    #     $SCRIPTS_DIR/led.py -c white # blinking red
    # elif [ $TEMP -ge 90 ]; then
    #     $SCRIPTS_DIR/led.py -c red
    # elif [ $TEMP -ge 75 ]; then
    #     $SCRIPTS_DIR/led.py -c orange
    # elif [ $TEMP -ge 65 ]; then
    #     $SCRIPTS_DIR/led.py -c yellow
    # elif [ $TEMP -ge 50 ]; then
    #     $SCRIPTS_DIR/led.py -c green
    # elif [ $TEMP -ge 32 ]; then
    #     $SCRIPTS_DIR/led.py -c blue
    # elif [ $TEMP -ge 15 ]; then
    #     $SCRIPTS_DIR/led.py -c cyan
    # elif [ $TEMP -ge 0 ]; then
    #     $SCRIPTS_DIR/led.py -c purple
    # elif [ $TEMP -ge -15 ]; then
    #     $SCRIPTS_DIR/led.py -c white
    # else
    #     $SCRIPTS_DIR/led.py -c red
    # fi
}

#!/bin/bash

function fg_black() {
    echo -ne "\033[0;30m"
}

function fg_blue() {
    echo -ne "\033[0;34m"
}

function fg_green() {
    echo -ne "\033[0;32m"
}

function fg_cyan() {
    echo -ne "\033[0;36m"
}

function fg_red() {
    echo -ne "\033[0;31m"
}

function fg_purple() {
    echo -ne "\033[0;35m"
}

function fg_brown() {
    echo -ne "\033[0;33m"
}

function fg_light_gray() {
    echo -ne "\033[0;37m"
}

function fg_dark_gray() {
    echo -ne "\033[1;30m"
}

function fg_light_blue() {
    echo -ne "\033[1;34m"
}

function fg_light_green() {
    echo -ne "\033[1;32m"
}

function fg_light_cyan() {
    echo -ne "\033[1;36m"
}

function fg_light_red() {
    echo -ne "\033[1;31m"
}

function fg_light_purple() {
    echo -ne "\033[1;35m"
}

function fg_yellow() {
    echo -ne "\033[1;33m"
}

function fg_white() {
    echo -ne "\033[1;37m"
}

function fg_random() {
    local RAND_VAL=$(( RANDOM % 14 ))
    case $RAND_VAL in
	0)
	    fg_green
	    # fg_black
	    ;;
	1)
	    fg_purple
	    # fg_blue
	    ;;
	2)
	    fg_green
	    ;;
	3)
	    fg_cyan
	    ;;
	4)
	    fg_red
	    ;;
	5)
	    fg_purple
	    ;;
	6)
	    fg_brown
	    ;;
	7)
	    fg_light_gray
	    ;;
	8)
	    fg_dark_gray
	    ;;
	9)
	    fg_light_blue
	    ;;
	10)
	    fg_light_green
	    ;;
	11)
	    fg_light_cyan
	    ;;
	12)
	    fg_light_red
	    ;;
	13)
	    fg_light_purple
	    ;;
	14)
	    fg_yellow
	    ;;
	15)
	    fg_white
	    ;;
    esac
}

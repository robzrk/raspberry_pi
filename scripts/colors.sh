#!/bin/bash
#set -x

function text_bold() {
    echo -ne "$(tput bold)"
}

function text_normal() {
    echo -ne "$(tput sgr0)"
}

function fg_default() {
    echo -ne "\033[0;39m"
}

function fg_black() {
    echo -ne "\033[0;30m"
}

function fg_red() {
    echo -ne "\033[0;31m"
}

function fg_green() {
    echo -ne "\033[0;32m"
}

function fg_brown() {
    echo -ne "\033[0;33m"
}

function fg_blue() {
    echo -ne "\033[0;34m"
}

function fg_purple() {
    echo -ne "\033[0;35m"
}

function fg_cyan() {
    echo -ne "\033[0;36m"
}

function fg_light_gray() {
    echo -ne "\033[0;37m"
}

function fg_dark_gray() {
    echo -ne "\033[1;30m"
}

function fg_light_red() {
    echo -ne "\033[1;31m"
}

function fg_light_green() {
    echo -ne "\033[1;32m"
}

function fg_yellow() {
    echo -ne "\033[1;33m"
}

function fg_light_blue() {
    echo -ne "\033[1;34m"
}

function fg_light_purple() {
    echo -ne "\033[1;35m"
}

function fg_light_cyan() {
    echo -ne "\033[1;36m"
}

function fg_white() {
    echo -ne "\033[1;37m"
}

function fg_random() {
    local RAND_VAL=$(( RANDOM % 16 ))
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
	    fg_light_gray
	    # fg_dark_gray
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

function bg_default() {
    echo -ne "\033[0;49m"
}

function bg_black() {
    echo -ne "\033[0;40m"
}

function bg_red() {
    echo -ne "\033[0;41m"
}

function bg_green() {
    echo -ne "\033[0;42m"
}

function bg_yellow() {
    echo -ne "\033[0;43m"
}

function bg_blue() {
    echo -ne "\033[0;44m"
}

function bg_magenta() {
    echo -ne "\033[0;45m"
}

function bg_cyan() {
    echo -ne "\033[0;46m"
}

function bg_light_gray() {
    echo -ne "\033[0;47m"
}

function bg_dark_gray() {
    echo -ne "\033[0;100m"
}

function bg_light_red() {
    echo -ne "\033[0;101m"
}

function bg_light_green() {
    echo -ne "\033[0;102m"
}

function bg_light_yellow() {
    echo -ne "\033[0;103m"
}

function bg_light_blue() {
    echo -ne "\033[0;104m"
}

function bg_light_magenta() {
    echo -ne "\033[0;105m"
}

function bg_light_cyan() {
    echo -ne "\033[0;106m"
}

function bg_white() {
    echo -ne "\033[0;107m"
}


function bg_random() {
    local RAND_VAL=$(( RANDOM % 16 ))
    case $RAND_VAL in
	0)
	    bg_black
	    ;;
	1)
	    bg_red
	    ;;
	2)
	    bg_green
	    ;;
	3)
	    bg_yellow
	    ;;
	4)
	    bg_blue
	    ;;
	5)
	    bg_magenta
	    ;;
	6)
	    bg_cyan
	    ;;
	7)
	    bg_light_gray
	    ;;
	8)
	    bg_dark_gray
	    ;;
	9)
	    bg_light_green
	    ;;
	10)
	    bg_light_red
	    ;;
	11)
	    bg_light_yellow
	    ;;
	12)
	    bg_light_blue
	    ;;
	13)
	    bg_light_magenta
	    ;;
	14)
	    bg_light_cyan
	    ;;
	15)
	    bg_white
	    ;;
    esac
}

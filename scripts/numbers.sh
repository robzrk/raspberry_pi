#!/bin/bash
SCRIPTS_DIR=~/raspberry_pi/scripts
source $SCRIPTS_DIR/print_lib.sh

function large_zero() {
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "00000000"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "0      0"
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "0      0"
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "0      0"
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "0      0"
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "0      0"
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "00000000"
}

function large_one() {
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "   1111 "
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "  1   1 "
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" " 1    1 "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "      1 "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "      1 "
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "      1 "
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "11111111"
}

function large_two() {
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "22222222"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "       2"
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "       2"
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" " 222222 "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "2       "
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "2       "
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "22222222"
}

function large_three(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "33333333"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "       3"
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "       3"
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" " 333333 "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "       3"
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "       3"
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "33333333"
}

function large_four(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "      4 "
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "    4 4 "
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "  4   4 "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "44444444"
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "      4 "
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "      4 "
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "      4 "
}

function large_five(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "55555555"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "5       "
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "5       "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" " 555555 "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "       5"
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "       5"
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "5555555 "
}

function large_six(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "66666666"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "6       "
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "6       "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "6666666 "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "6      6"
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "6      6"
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "66666666"
}

function large_seven(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "77777777"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "       7"
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "      7 "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "     7  "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "    7   "
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "   7    "
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "  7     "
}

function large_eight(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "88888888"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "8      8"
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "8      8"
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" " 888888 "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "8      8"
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "8      8"
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "88888888"
}

function large_nine(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "99999999"
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "9      9"
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "9      9"
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" " 9999999"
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "       9"
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "       9"
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "99999999"
}

function large_dot(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "o "
}

function large_dash(){
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+1)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+2)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+3)) $C
    print_lock "-n" "--"
    cm_move_cursor_to_point $((L+4)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+5)) $C
    print_lock "-n" "  "
    cm_move_cursor_to_point $((L+6)) $C
    print_lock "-n" "  "
}

function print_large_digit() {
    local DIGIT=$1
    local L=$2
    local C=$3
    case $DIGIT in
	0)
	    large_zero $L $C
	    ;;
	1)
	    large_one $L $C
	    ;;
	2)
	    large_two $L $C
	    ;;
	3)
	    large_three $L $C
	    ;;
	4)
	    large_four $L $C
	    ;;
	5)
	    large_five $L $C
	    ;;
	6)
	    large_six $L $C
	    ;;
	7)
	    large_seven $L $C
	    ;;
	8)
	    large_eight $L $C
	    ;;
	9)
	    large_nine $L $C
	    ;;
	.)
	    large_dot $L $C
	    ;;
	-)
	    large_dash $L $C
	    ;;
	*)
	    return
	    ;;
    esac
}

# 1, 2 or 3-digit number
function print_large_number() {
    local NUMBER=$1
    local PLN_LINE=$2
    local PLN_COL=$3

    if [ "$NUMBER" == "" -o "$PLN_LINE" == "" -o "$PLN_COL" == "" ]; then
	return
    fi

    local PLN_DIGIT=0
    local PRINT_DIGIT=`echo ${NUMBER:$DIGIT:$((DIGIT+1))}`
    while [ "$PRINT_DIGIT" != "" ]; do
	print_large_digit $PRINT_DIGIT $PLN_LINE $PLN_COL
	PLN_DIGIT=$((PLN_DIGIT+1))
	if [ "$PRINT_DIGIT" == "." -o "$PRINT_DIGIT" == "-" ]; then
	    PLN_COL=$((PLN_COL+3))
	else
	    PLN_COL=$((PLN_COL+9))
	fi
	PRINT_DIGIT=`echo ${NUMBER:$PLN_DIGIT:1}`
    done
}

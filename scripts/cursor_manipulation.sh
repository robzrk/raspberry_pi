#!/bin/bash

function cm_move_cursor_to_point() {
    local L=$1
    local C=$2
    echo -ne "\033[${L};${C}H"
    # \033[<L>;<C>f
}

function cm_move_cursor_up_N() {
    local N=$1
    echo -ne "\033[${N}A"
}

function cm_move_cursor_down_N() {
    local N=$1
    echo -ne "\033[${N}B"
}

function cm_move_cursor_right_N() {
    local N=$1
    echo -ne "\033[${N}C"
}

function cm_move_cursor_left_N() {
    local N=$1
    echo -ne "\033[${N}D"
}

function cm_clear_screen() {
    echo -ne "\033[2J"
}

function cm_clear_current_line() {
    echo -ne "\033[K"
}

function cm_clear_specified_line() {
    local L=$1
    local C=$2
    cm_move_cursor_to_point $L $C
    echo -ne "\033[K"
}

function cm_save_cursor_position() {
    echo -ne "\033[s"
}

function cm_restore_cursor_position() {
    echo -ne "\033[u"
}

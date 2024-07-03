#!/usr/bin/env bash

source $PREFERENCES_DIR/util/override.sh

function loadTerm {
    local colorSet=$1
    local fontSet=$2
    local titleSet=$3

    [ -z $colorSet ] && function setTermColor { :; } || source $PREFERENCES_TERM/color/$colorSet.sh
    [ -z $fontSet ] && function setTermFont { :; } || source $PREFERENCES_TERM/font/$fontSet.sh
    [ -z $titleSet ] && function setTermTitle { :; } || source $PREFERENCES_TERM/title/$titleSet.sh
}

function loadTerms {
    # Don't bother the shell within vim terminal
    [[ -z ${VIM:+x} ]] || loadTerm '' '' ''

    case $PREFERENCES_OS in
        'Darwin')
            case $TERM_PROGRAM in
                'iTerm'*)
                    loadTerm 'iterm2' '' 'iterm2'
                    ;;
                *)
                    if [ -n "$KITTY_PID" ] && [ $KITTY_PID > 0 ]; then
                        loadTerm 'xtermcontrol' 'kitty' 'xtermcontrol'
                    else
                        loadTerm 'xtermcontrol' 'apple_terminal' 'xtermcontrol'
                    fi
                    ;;
            esac
            ;;
        *)
            local terminal=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))")

            case $terminal in
                'gnome-terminal'*)
                    loadTerm 'xtermcontrol' 'gnome_terminal' 'xtermcontrol'
                    ;;
                'kgx') # gnome-console
                    loadTerm 'xtermcontrol' '' 'xtermcontrol'
                    ;;
                *)
                    loadTerm 'xtermcontrol' '' 'xtermcontrol'
                    ;;
            esac
            ;;
    esac
}

function setTerm {
    local profile=$(echo $1 | sed 's/^profile_\(.*\)/\1/')
    local title=$2

    setTermColor $profile
    setTermFont $profile
    setTermTitle $profile $title
}

function defaultTerm {
    setTerm profile_default
}


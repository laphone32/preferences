#!/usr/bin/env bash

source $PREFERENCES_DIR/util/override.sh

function loadTerm {
    [ -z "$1" ] && function setTermColor { :; } || source $PREFERENCES_TERM/color/$1.sh
    [ -z "$2" ] && function setTermFont { :; } || source $PREFERENCES_TERM/font/$2.sh
    [ -z "$3" ] && function setTermTitle { :; } || source $PREFERENCES_TERM/title/$3.sh
}

function loadTerms {
    # Don't bother the shell within vim terminal
    [[ -z ${VIM:+x} ]] || return

    case $OSTYPE in
        'darwin'*)
            case $TERM_PROGRAM in
                'iTerm'*)
                    loadTerm 'iterm2' '' 'iterm2'
                    ;;
                *)
                    loadTerm 'xtermcontrol' 'apple_terminal' 'xtermcontrol'
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
    local profile=$(echo $1 | sed 's/^profile_\(.*\)/\1/p')
    local title=$2

    setTermColor $1
    setTermFont $1
    setTermTitle $1 $2
}

function defaultTerm {
    setTerm profile_default
}


#!/usr/bin/env bash

function setTermFont {
    local name size

    case $1 in
        "vim" )
            font="Monaco"
            size="23"
            ;;
        "prod" )
            font="SF Mono"
            size="20"
            ;;
        "uat" )
            font="SF Mono"
            size="20"
            ;;
        "remote" )
            font="SF Mono"
            size="20"
            ;;
        "container" )
            font="SF Mono"
            size="20"
            ;;
        *)
            font="Monaco"
            size="20"
            ;;
    esac
    osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$font\""
    osascript -e "tell application \"Terminal\" to set the font size of window 1 to $size"
}


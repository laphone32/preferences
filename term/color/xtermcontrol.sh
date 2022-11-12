#/bin/bash

function setColor {
    local file="" foreground="white" background
    local colorPath="$PREFERENCES_TERM/color/xterm"

    case $1 in
        "vim")
            file="nord-xtermcontrol"
            ;;
        "prod")
            background="#691B1B"
            ;;
        "uat")
            background="#245524"
            ;;
        "remote")
            background="#34346565a4a4"
            ;;
        "docker")
            background="#0b0a2b"
            ;;
        *)
            background="#555557575353"
            ;;
    esac

    if [[ $file == "" ]]; then
        xtermcontrol --fg=$foreground --bg=$background
    else
        xtermcontrol --file=$colorPath/$file
    fi
}


#/bin/bash

function setColor {
    local profile="" foreground="white" background
    local colorPath="$PREFERENCES_TERM/color/profile"

    case $1 in
        "vim")
            profile="vim"
            ;;
        "prod")
            profile="prod"
#            background="#691B1B"
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
            profile="default"
#            background="#555557575353"
            ;;
    esac

    if [[ $profile == "" ]]; then
        xtermcontrol --fg=$foreground --bg=$background
    else
        xtermcontrol --file=$colorPath/$profile
    fi
}


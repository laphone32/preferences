#/bin/bash

function setTerm {
    local file="" foreground="white" background title
    local xtermPath="$PREFERENCES_TERM/xterm"

    case $1 in
        "vim")
            file="nord-xtermcontrol"
            title="[Vim]"
            ;;
        "prod")
            background="#691B1B"
            title="> PROD <"
            ;;
        "uat")
            background="#245524"
            title="> UAT <"
            ;;
        "remote")
            background="#34346565a4a4"
            title="> REMOTE <"
            ;;
        "docker")
            background="#0b0a2b"
            title="> Container <"
            ;;
        *)
            background="#555557575353"
            title="[LOCAL]"
            ;;
    esac

    if [[ $file == "" ]]; then
        xtermcontrol --fg=$foreground --bg=$background --title=$title
    else
        xtermcontrol --file=$xtermPath/$file --title=$title
    fi
}

export -f setTerm


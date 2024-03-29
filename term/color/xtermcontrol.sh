#!/usr/bin/env bash

function setTermColor {
    local profile=$1

    [ ! -f "$PREFERENCES_TERM/color/profile/$profile" ] && profile="default"

    local cache=_termColor_$profile

    if [ -z ${!cache+x} ]; then
        function setArgs {
            local var=$1 arg=$2
            echo ${!var:+$arg=${!var} }
        }

        eval $( source $PREFERENCES_TERM/color/profile/$profile
            echo $cache=\"\
            $(setArgs background --bg)\
            $(setArgs foreground --fg)\
            $(setArgs cursor --cursor)\
            $(setArgs highlightBg --highlight)\
            $(setArgs color0  --color0)\
            $(setArgs color1  --color1)\
            $(setArgs color2  --color2)\
            $(setArgs color3  --color3)\
            $(setArgs color4  --color4)\
            $(setArgs color5  --color5)\
            $(setArgs color6  --color6)\
            $(setArgs color7  --color7)\
            $(setArgs color8  --color8)\
            $(setArgs color9  --color9)\
            $(setArgs color10 --color10)\
            $(setArgs color11 --color11)\
            $(setArgs color12 --color12)\
            $(setArgs color13 --color13)\
            $(setArgs color14 --color14)\
            $(setArgs color15 --color15)\
            \")
    fi

    xtermcontrol ${!cache}
}


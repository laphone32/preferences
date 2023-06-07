#!/usr/bin/env bash

# Ref: https://iterm2.com/documentation-escape-codes.html

function setTermColor {
    local profile=$1

    [ ! -f "$PREFERENCES_TERM/color/profile/$profile" ] && profile="default"

    local cache=_termColor_$profile
    function loadTermColor {
        function setControlSeq {
            local var=$1 key=$2
            echo ${!var:+\\033]1337;SetColors=$key=${!var#\#}\\033\\\\}
        }

        source $PREFERENCES_TERM/color/profile/$profile
        eval "$cache=\"
            $(setControlSeq background \"bg\")
            $(setControlSeq foreground \"fg\")
            $(setControlSeq cursor curfg)
            $(setControlSeq color0 black)
            $(setControlSeq color1 red)
            $(setControlSeq color2 green)
            $(setControlSeq color3 yellow)
            $(setControlSeq color4 blue)
            $(setControlSeq color5 magenta)
            $(setControlSeq color6 cyan)
            $(setControlSeq color7 white)
            $(setControlSeq color8 br_black)
            $(setControlSeq color9 br_red)
            $(setControlSeq color10 br_green)
            $(setControlSeq color11 br_yellow)
            $(setControlSeq color12 br_blue)
            $(setControlSeq color13 br_magenta)
            $(setControlSeq color14 br_cyan)
            $(setControlSeq color15 br_white)

            $(setControlSeq bold bold)
            $(setControlSeq cursorBg curbg)
            $(setControlSeq highlightFg selfg)
            $(setControlSeq highlightBg selbg)
            \r
        \""
    }
    [[ -z ${!cache} ]] && loadTermColor

    echo -ne ${!cache}
}


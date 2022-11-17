#/bin/bash

function setTermColor {
    local profile=$PREFERENCES_TERM/color/profile/$1
    [ ! -f "$profile" ] && profile=$PREFERENCES_TERM/color/profile/default

    xtermcontrol --file=$profile
}


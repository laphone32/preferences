#/bin/bash

function setTermTitle {
    source $PREFERENCES_TERM/title/titles.sh

    local title="${1}_title"

    xtermcontrol --title=${!title:-$default_title}
}


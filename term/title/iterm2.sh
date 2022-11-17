#/bin/bash

function setTermTitle {
    source $PREFERENCES_TERM/title/titles.sh

    local title="${1}_title"

    echo -ne "\033]0;${!title:-$default_title}\007"
}


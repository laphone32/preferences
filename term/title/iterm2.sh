#/bin/bash

function setTitle {
    source $PREFERENCES_TERM/title/titles.sh

    local title="${1}_title"
    title=${!title:=$default_title}

    echo -ne "\033]0;$title\007"
}


#!/usr/bin/env bash

function setTermTitle {
    local cache=term_title_${1}

    if [[ -z ${!cache} ]]; then
        if [[ -z $term_title_default ]]; then
            source $PREFERENCES_TERM/title/titles.sh
        else
            cache=term_title_default
        fi
    fi

    echo -ne "\033]0;${!cache} $2\007"
}


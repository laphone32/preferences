#/bin/bash

function setTermTitle {
    local cache=_termTitle_${1}

    function loadTermTitle {
        function setCache {
            local profile=$1
            eval "_termTitle_$profile=\$${profile}_title"
        }

        source $PREFERENCES_TERM/title/titles.sh

        setCache default
        setCache vim
        setCache prod
        setCache uat
        setCache container
        setCache remote
    }
    if [[ -z ${!cache} ]]; then
        if [[ -z $_termTitle_default ]]; then
            loadTermTitle
        else
            cache=_termTitle_default
        fi
    fi

    xtermcontrol --title="${!cache} $2"
}


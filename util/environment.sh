#!/bin/env bash

# Linux | Windows | Darwin
function currentOs {
    case $OSTYPE in
        'darwin'*)
            echo 'Darwin'
            ;;
        'linux'*)
            echo 'Linux'
            ;;
        *)
            echo 'Windows'
            ;;
    esac
}
PREFERENCES_OS=$(currentOs)

function currentLinuxDesktopEnvironment {
    local checkTags=('xfc' 'kde' 'unity' 'gnome' 'cinnamon' 'mate' 'deepin' 'budgie' 'lxqt')
    local de=''

    function checkVariable {
        local target=$(echo $1 | tr '[:upper:]' '[:lower:]')

        for tag in ${checkTags[@]}; do
            [[ "$target" =~ "$tag" ]] && de=$tag
        done
    }

    checkVariable $XDG_CURRENT_DESKTOP

    [ -z "$de" ] && checkVariable $GDMSESSION

    echo $de
}
PREFERENCES_DESKTOP_ENVIRONMENT=$(currentLinuxDesktopEnvironment)

PREFERENCES_WORKSPACE="$PREFERENCES_DIR/.workspace"


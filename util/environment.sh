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


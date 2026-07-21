#!/usr/bin/env bash
[[ "${_PREFERENCES_UTIL_ENVIRONMENT_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_ENVIRONMENT_SOURCED=yes


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

function currentDistro {
    case $PREFERENCES_OS in
        'Darwin')
            echo 'macos'
            ;;
        'Windows')
            echo 'windows'
            ;;
        *)
            local os_file=""
            if [ -f /etc/os-release ]; then
                os_file="/etc/os-release"
            elif [ -f /usr/lib/os-release ]; then
                os_file="/usr/lib/os-release"
            fi

            if [ -n "$os_file" ]; then
                local distro
                distro=$(grep -E '^ID=' "$os_file" | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
                echo "${distro:-linux}"
            else
                echo "linux"
            fi
            ;;
    esac
}
PREFERENCES_DISTRO=$(currentDistro)

function currentDistroLike {
    case $PREFERENCES_OS in
        'Darwin')
            echo 'macos'
            ;;
        'Windows')
            echo 'windows'
            ;;
        *)
            local os_file=""
            if [ -f /etc/os-release ]; then
                os_file="/etc/os-release"
            elif [ -f /usr/lib/os-release ]; then
                os_file="/usr/lib/os-release"
            fi

            if [ -n "$os_file" ]; then
                local distro_like
                distro_like=$(grep -E '^ID_LIKE=' "$os_file" | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
                echo "${distro_like:-$PREFERENCES_DISTRO}"
            else
                echo "$PREFERENCES_DISTRO"
            fi
            ;;
    esac
}
PREFERENCES_DISTRO_LIKE=$(currentDistroLike)

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


#!/usr/bin/env bash
[[ "${_PREFERENCES_UTIL_UTILS_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_UTILS_SOURCED=yes

function isSubDirValid {
    local dir=$1
    local onlyForFile="${dir}only_for.sh"

    if [ ! -f "$onlyForFile" ]; then
        return 0
    fi

    # Reset restriction variables before sourcing
    local ONLY_FOR_OS=()
    local ONLY_FOR_DE=()
    local ONLY_FOR_DISTRO=()

    # Source the restriction file
    source "$onlyForFile"

    # Check OS restrictions (e.g., 'Linux', 'Darwin', 'Windows')
    if [ ${#ONLY_FOR_OS[@]} -gt 0 ]; then
        local os_matched=1
        for target_os in "${ONLY_FOR_OS[@]}"; do
            if [ "$target_os" == "$PREFERENCES_OS" ]; then
                os_matched=0
                break
            fi
        done
        if [ $os_matched -ne 0 ]; then
            return 1
        fi
    fi

    # Check Desktop Environment restrictions (e.g., 'gnome', 'kde', etc.)
    if [ ${#ONLY_FOR_DE[@]} -gt 0 ]; then
        local de_matched=1
        for target_de in "${ONLY_FOR_DE[@]}"; do
            if [ "$target_de" == "$PREFERENCES_DESKTOP_ENVIRONMENT" ]; then
                de_matched=0
                break
            fi
        done
        if [ $de_matched -ne 0 ]; then
            return 1
        fi
    fi

    # Check Distro restrictions (e.g., 'ubuntu', 'arch', etc.)
    if [ ${#ONLY_FOR_DISTRO[@]} -gt 0 ]; then
        local distro_matched=1
        for target_distro in "${ONLY_FOR_DISTRO[@]}"; do
            if [ "$target_distro" == "$PREFERENCES_DISTRO" ] || [ "$target_distro" == "$PREFERENCES_DISTRO_LIKE" ]; then
                distro_matched=0
                break
            fi
        done
        if [ $distro_matched -ne 0 ]; then
            return 1
        fi
    fi

    return 0
}

function eachValidSubFile {
    local action=$1
    local name=$2
    local targetDir="$PREFERENCES_DIR"

    for dir in $targetDir/*/; do
        if [ -e "$dir$name" ] && isSubDirValid "$dir"; then
            eval "$action $dir$name"
        fi
    done
}

function eachSubFile {
    local targetDir=$1
    local action=$2
    local name=$3

    for dir in $targetDir/*/; do
        if [ -e "$dir$name" ]; then
            eval "$action $dir$name"
        fi
    done
}

function findNearestParent {
    local path=$1
    local name=$2

    while [[ "$path" != / ]] && [[ "$path" != . ]];
    do
        local target="$path/$name"
        if [ -f "$target" ]; then
            echo $target
            break
        fi
        path="$(readlink -f "$path"/..)"
    done
}

function updateOrInsertSection {
    local fileName=$1
    local section=$2
    local content=$3
    local scriptDir="${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/util"

    python3 "$scriptDir/update_section.py" "$fileName" "$section" "$content"
}

function workspace {
    local module=$1
    echo "$PREFERENCES_WORKSPACE/$module"
}

function githubLatestRelease {
    local user=$1
    local repo=$2

    local tag=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/$user/$repo/releases/latest 2>/dev/null))
    if [ "$tag" != "latest" ] && [ -n "$tag" ]; then
        echo "$tag"
    fi
}


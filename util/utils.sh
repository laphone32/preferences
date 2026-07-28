#!/usr/bin/env bash
[[ "${_PREFERENCES_UTIL_UTILS_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_UTILS_SOURCED=yes

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


#!/usr/bin/env bash
[[ "${_PREFERENCES_UTIL_UTILS_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_UTILS_SOURCED=yes



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
    local isSudo=${4:-false}
    local scriptDir="${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/util"

    local expectedBlock="### ${section} ###"$'\n'"${content}"$'\n'"### end of ${section} ###"

    if [ -f "$fileName" ] && [ -r "$fileName" ]; then
        local currentContent
        currentContent=$(<"$fileName")
        if [[ "$currentContent" == *"$expectedBlock"* ]]; then
            return 0
        fi
    fi

    local sudoCmd=""
    if [ "$isSudo" == "true" ] || [ "$isSudo" == "yes" ] || [ "$isSudo" == "1" ] || [ "$isSudo" == "sudo" ]; then
        sudoCmd="sudo "
    fi

    $sudoCmd mkdir -p "$(dirname "$fileName")"
    $sudoCmd python3 "$scriptDir/update_section.py" "$fileName" "$section" "$content"
}

function deleteSection {
    local fileName=$1
    local section=$2
    local isSudo=${3:-false}
    local scriptDir="${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/util"

    if [ -f "$fileName" ]; then
        local sudoCmd=""
        if [ "$isSudo" == "true" ] || [ "$isSudo" == "yes" ] || [ "$isSudo" == "1" ] || [ "$isSudo" == "sudo" ]; then
            sudoCmd="sudo "
        fi

        $sudoCmd python3 "$scriptDir/update_section.py" --delete "$fileName" "$section"
    fi
}

function workspace {
    local module=${1:-""}
    if [ -n "$module" ]; then
        echo "$PREFERENCES_WORKSPACE/$module"
    else
        echo "$PREFERENCES_WORKSPACE"
    fi
}

function githubLatestRelease {
    local user=$1
    local repo=$2

    local tag=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/$user/$repo/releases/latest 2>/dev/null))
    if [ "$tag" != "latest" ] && [ -n "$tag" ]; then
        echo "$tag"
    fi
}


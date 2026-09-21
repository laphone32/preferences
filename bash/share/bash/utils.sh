#!/usr/bin/env bash
# File: bash/share/bash/utils.sh

[[ "${_PREFERENCES_BASH_UTILS_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_BASH_UTILS_SOURCED=yes

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

function workspace {
    local module=${1:-""}
    local base_ws="${PREFERENCES_WORKSPACE:-$PREFERENCES_DIR/.workspace}"
    if [ -n "$module" ]; then
        echo "$base_ws/$module"
    else
        echo "$base_ws"
    fi
}

function share {
    local module=$1
    local type=${2:-""}    # "bash" or "python"
    local file=${3:-""}

    local target="$PREFERENCES_DIR/$module/share"
    [ -n "$type" ] && target="$target/$type"
    [ -n "$file" ] && target="$target/$file"
    echo "$target"
}

function shareBash {
    local module=$1
    local file=${2:-""}
    share "$module" "bash" "$file"
}

function sharePython {
    local module=$1
    local file=${2:-""}
    share "$module" "python" "$file"
}

function sourceShare {
    local module=$1
    local file=$2
    local target="$(shareBash "$module" "$file")"
    if [ -f "$target" ]; then
        source "$target"
    else
        echo "❌ Error: Cannot source shared bash library '$target' (not found)." >&2
        return 1
    fi
}

function updateOrInsertSection {
    local fileName=$1
    local section=$2
    local content=$3
    local isSudo=${4:-false}
    local scriptPath="$(sharePython install update_section.py)"

    local expectedBlock="### ${section} ###"$'\n'"${content}"$'\n'"### end of ${section} ###"
    if [[ "$fileName" == *.lua ]]; then
        expectedBlock="-- ### ${section} ###"$'\n'"${content}"$'\n'"-- ### end of ${section} ###"
    fi

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
    $sudoCmd python3 "$scriptPath" "$fileName" "$section" "$content"
}

function deleteSection {
    local fileName=$1
    local section=$2
    local isSudo=${3:-false}
    local scriptPath="$(sharePython install update_section.py)"

    if [ -f "$fileName" ]; then
        local sudoCmd=""
        if [ "$isSudo" == "true" ] || [ "$isSudo" == "yes" ] || [ "$isSudo" == "1" ] || [ "$isSudo" == "sudo" ]; then
            sudoCmd="sudo "
        fi

        $sudoCmd python3 "$scriptPath" --delete "$fileName" "$section"
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

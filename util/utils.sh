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

    local headNote="### $section ###"
    local footNote="### end of $section ###"

    local leadLine="^$headNote\$"
    local tailLine="^$footNote\$"

    tmpFileName="$fileName.tmp"

    sed -e "
    /$leadLine/,/$tailLine/{
    h
    /$leadLine/{
    p
    a \\
$content
    }
    /$tailLine/p
    d
    }
    \${
    x
    /^$/{
    s||$headNote\\n$content\\n$footNote\\n|
    H
    }
    x
    }" $fileName > $tmpFileName && mv $tmpFileName $fileName
}

function workspace {
    local module=$1
    echo "$PREFERENCES_WORKSPACE/$module"
}

function githubLatestRelease {
    local user=$1
    local repo=$2

    basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/$user/$repo/releases/latest)

}


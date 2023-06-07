#!/usr/bin/env bash

function eachSubFile {
    local targetDir=$1
    local action=$2
    local fileName=$3

    for dir in $targetDir/*/; do
        if [ -f "$dir$fileName" ]; then
            eval "$action $dir$fileName"
        fi
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



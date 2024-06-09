#!/usr/bin/env bash

function pythonVenvPath {
    local path=$1
    echo "$path/.pvenv"
}

function pythonVenvCreate {
    local name=$1
    local venvPath=$2

    python -m venv $venvPath --prompt $name
}

function pythonVenvStart {
    local venvPath=$1

    source $venvPath/bin/activate
    alias exit='deactivate; unalias exit'
}

function pythonVenvOn {
    python -c 'import sys; print (sys.prefix != sys.base_prefix)' 2>/dev/null
}

function pvenv {
    if [ $(pythonVenvOn) == 'False' ]; then
        local dir=$PWD
        local requirements=($PREFERENCES_DIR/python/requirements.txt)
        local nearestRequirement=$(findNearestParent $PWD "requirements.txt")

        if [ -f $nearestRequirement ]; then
            dir=$(dirname "$nearestRequirement")
            requirements+=($nearestRequirement)
        fi

        local container=$(pythonVenvPath "$dir")
        if [ ! -d "$container" ]; then
            echo "Creating python vitual environment in $container"
            pythonVenvCreate "$(basename "$dir")_venv" $container
        fi

        echo "Starting python vitual environment in $container"
        pythonVenvStart $container

        echo "Initialising python vitual environment in $container with (${requirements[@]})"
        for file in "${requirements[@]}"; do
            python -m pip install --upgrade -r $file
        done
    else
        echo 'Already in python vitual environment'
    fi
}


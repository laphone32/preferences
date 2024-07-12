#!/usr/bin/env bash

function pythonVenvCreateOnce {
    local name=$1
    local container="$2/.pvenv"

    if [ ! -d "$container" ]; then
        echo "Creating python vitual environment in $container"
        python3 -m venv $container --prompt "${name}_venv"
    fi
}

function pythonVenvStart {
    local container="$1/.pvenv"

    source $container/bin/activate
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

        if [ -z ${nearestRequirement+x} ] && [ -f $nearestRequirement ]; then
            dir=$(dirname "$nearestRequirement")
            requirements+=($nearestRequirement)
        else
            dir=$PREFERENCES_WORKSPACE_PYTHON
        fi

        pythonVenvCreateOnce $(basename "$dir") $dir

        echo "Starting python vitual environment in $dir"
        pythonVenvStart $dir

        echo "Initialising python vitual environment in $dir with (${requirements[@]})"
        for file in "${requirements[@]}"; do
            python -m pip install --upgrade -r $file
        done
    else
        echo 'Already in python vitual environment'
    fi
}


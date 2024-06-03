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


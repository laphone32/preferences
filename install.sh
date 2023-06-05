#!/bin/bash


PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $PREFERENCES_DIR/util/utils.sh

function echoAndSource {
    local arg=$1
    echo "source $arg"
    source $arg
}

eachSubFile "$PREFERENCES_DIR" 'echoAndSource' 'install.sh'


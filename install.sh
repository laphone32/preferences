#!/usr/bin/env bash

PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $PREFERENCES_DIR/util/environment.sh
source $PREFERENCES_DIR/util/utils.sh


# Required software
case $PREFERENCES_OS in
    'Darwin')
        requirements=('brew' 'curl' 'git' 'node' 'npm' 'rg' 'vim' 'xtermcontrol')
        ;;
    'Linux')
        requirements=('curl' 'git' 'node' 'npm' 'rg' 'vim' 'xtermcontrol')
        ;;
    *)
        requirements=()
        ;;
esac

for commandName in ${requirements[@]}; do
    if ! [ -x "$(command -v $commandName)" ]; then
        echo "Required software [$commandName] not found, install requirements { ${requirements[@]} } first."
        exit 1
    fi
done
echo "Required software all met"

# workspace
mkdir -p "$(workspace '')"


# module installation
function echoAndSource {
    local arg=$1
    echo "source $arg"
    source $arg
}

if [ "$#" -ge 1 ]; then
    echoAndSource $PREFERENCES_DIR/$1/install.sh
else
    eachSubFile "$PREFERENCES_DIR" 'echoAndSource' 'install.sh'
fi

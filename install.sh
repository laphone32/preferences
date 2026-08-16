#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/util/bootstrap.sh"


source "$PREFERENCES_DIR/install/package.sh"
if ! installNecessaryPackages; then
    echo "❌ Error: Required package installation incomplete. Aborting installation."
    exit 1
fi

# workspace
installPreferencesDir "$(workspace '')"


# module installation
function echoAndSource {
    local arg=$1
    echo "source $arg"
    source $arg
}

if [ "$#" -ge 1 ]; then
    for module in "$@"; do
        echoAndSource "$PREFERENCES_DIR/$module/install.sh"
    done
else
    eachValidSubFile 'echoAndSource' 'install.sh'
fi

#!/usr/bin/env bash

source $PREFERENCES_DIR/util/utils.sh

install="\
export PREFERENCES_DIR=\'$PREFERENCES_DIR\'\\
[[ -s \"\$PREFERENCES_DIR/bash/bashrc_loader\" ]] && source \"\$PREFERENCES_DIR/bash/bashrc_loader\"\
"

bashProfileName="$HOME/.bashrc"
if [ ! -f $bashProfileName ]; then
    bashProfileName="$HOME/.bash_profile"
fi

if [ -f $bashProfileName ]; then
    echo "install to $bashProfileName"
    updateOrInsertSection $bashProfileName 'laphone preferences' "$install"
else
    echo "Cannot find neither .bashrc nor .bash_profile"
fi


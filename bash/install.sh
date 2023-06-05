#!/bin/bash

source $PREFERENCES_DIR/util/utils.sh

install="\
export PREFERENCES_DIR=$PREFERENCES_DIR\\
source \$PREFERENCES_DIR/bash/bashrc\
"

bashProfileName="$HOME/.bashrc"
if [ ! -f $bashProfileName ]; then
    bashProfileName="$HOME/.bash_profile"
fi

if [ -f $bashProfileName ]; then
    echo "insatll to $bashProfileName"
    updateOrInsertSection $bashProfileName 'laphone preferences' "$install"
else
    echo "Cannot find neither .bashrc nor .bash_profile"
fi


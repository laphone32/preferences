#!/bin/bash

BASH_PROFILE_NAME="$HOME/.bashrc"
if [ ! -f $BASH_PROFILE_NAME ]; then
    BASH_PROFILE_NAME="$HOME/.bash_profile"
fi

if [ -f $BASH_PROFILE_NAME ]; then
    echo -e "\n\
#laphone preferences\n\
export PREFERENCES_DIR=$PREFERENCES_DIR\n\
source $PREFERENCES_DIR/bash/bashrc\n\
\n" >> $BASH_PROFILE_NAME
else
    echo "Cannot find neither .bashrc nor .bash_profile"
fi



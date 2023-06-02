#!/bin/bash

PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# Ideavim
ln -s $PREFERENCES_DIR/vim/ideavimrc $HOME/.ideavimrc

# vim
mkdir -p $HOME/.vim

# git
git config --global core.excludesfile $PREFERENCES_DIR/gitignore
git config --global user.useConfigOnly true

# systemd
$PREFERENCES_DIR/systemd/install.sh


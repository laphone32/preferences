#!/bin/bash

source $PREFERENCES_TERM/wrapper.sh

setTerm vim
vim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/vimrc $@

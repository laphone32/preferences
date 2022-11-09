#!/bin/bash

source $PREFERENCES_BIN/term_util.sh

$LAPHONE_VIM_TERM
vim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vimrc $@

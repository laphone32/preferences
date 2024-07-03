#!/usr/bin/env bash

source $PREFERENCES_DIR/kitty/common.sh

function setTermFont {
    profile=$1
    [ ! -f "$PREFERENCES_KITTY/fonts/$profile.conf" ] && profile="default"

    ln -sf $PREFERENCES_KITTY/fonts/$profile.conf $PREFERENCES_KITTY_LOCAL/fonts.conf

    kill -SIGUSR1 $KITTY_PID
}


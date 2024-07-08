#!/usr/bin/env bash

source $PREFERENCES_DIR/kitty/common.sh

function setTermColor {
    local profile=$1

    [ ! -f "$PREFERENCES_WORKSPACE_KITTY/color-theme/$profile.conf" ] && profile='default'

    ln -sf $PREFERENCES_WORKSPACE_KITTY/color-theme/$profile.conf $PREFERENCES_KITTY_LOCAL/theme.conf

    kill -SIGUSR1 $KITTY_PID
}


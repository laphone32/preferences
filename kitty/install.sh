#!/usr/bin/env bash

source $PREFERENCES_DIR/kitty/common.sh

ln -sf $PREFERENCES_KITTY/config/kitty.conf $PREFERENCES_KITTY_LOCAL/kitty.conf
ln -sf $PREFERENCES_KITTY/fonts/default.conf $PREFERENCES_KITTY_LOCAL/fonts.conf
ln -sf $PREFERENCES_KITTY/config/current-theme.conf $PREFERENCES_KITTY_LOCAL/current-theme.conf

case $PREFERENCES_OS in
    'Darwin')
        ln -sf $PREFERENCES_DIR/kitty/config/kitty_macos.conf $PREFERENCES_KITTY_LOCAL/kitty_os.conf
        ;;
    'Linux')
        ln -sf $PREFERENCES_DIR/kitty/config/kitty_linux.conf $PREFERENCES_KITTY_LOCAL/kitty_os.conf
        ;;
    *)
        ;;
esac


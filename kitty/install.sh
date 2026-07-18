#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/kitty/common.sh

# Ensure ~/.local/bin is in PATH for the current shell execution
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi



installPreferencesDir $PREFERENCES_KITTY_LOCAL
installPreferencesDir $PREFERENCES_WORKSPACE_KITTY

PREFERENCES_KITTY_CONFIG="$PREFERENCES_KITTY/config"

# shell
DEFAULT_SHELL=$(which bash) envsubst '$DEFAULT_SHELL' < $PREFERENCES_KITTY_CONFIG/device.conf.template > $PREFERENCES_WORKSPACE_KITTY/device.conf
installPreferencesSymlink $PREFERENCES_WORKSPACE_KITTY/device.conf $PREFERENCES_KITTY_LOCAL/device.conf


# color scheme
installPreferencesDir $PREFERENCES_WORKSPACE_KITTY/color-theme
function dump_theme {
    kitty +kitten themes --dump-theme $1 > $PREFERENCES_WORKSPACE_KITTY/color-theme/$2.conf
}
dump_theme 'Chalk' 'default'
dump_theme 'Nord' 'vim'
dump_theme 'Vaughn' 'remote'
dump_theme 'Earthsong' 'container'
dump_theme 'Solarized Darcula' 'uat'
dump_theme 'Red Alert' 'prod'

installPreferencesSymlink $PREFERENCES_WORKSPACE_KITTY/color-theme/default.conf $PREFERENCES_KITTY_LOCAL/theme.conf


# os specific
case $PREFERENCES_OS in
    'Darwin')
        installPreferencesSymlink $PREFERENCES_DIR/kitty/os/kitty_macos.conf $PREFERENCES_KITTY_LOCAL/os.conf
        ;;
    'Linux')
        installPreferencesSymlink $PREFERENCES_DIR/kitty/os/kitty_linux.conf $PREFERENCES_KITTY_LOCAL/os.conf
        ;;
    *)
        ;;
esac


# fonts
installPreferencesSymlink $PREFERENCES_KITTY/fonts/default.conf $PREFERENCES_KITTY_LOCAL/fonts.conf


# watcher
PREFERENCES_DIR=$PREFERENCES_DIR PREFERENCES_KITTY_LOCAL=$PREFERENCES_KITTY_LOCAL envsubst '$PREFERENCES_DIR,$PREFERENCES_KITTY_LOCAL' < $PREFERENCES_KITTY_CONFIG/watcher.py.template > $PREFERENCES_WORKSPACE_KITTY/watcher.py
installPreferencesSymlink $PREFERENCES_WORKSPACE_KITTY/watcher.py $PREFERENCES_KITTY_LOCAL/watcher.py


# configs
installPreferencesSymlink $PREFERENCES_KITTY_CONFIG/kitty.conf $PREFERENCES_KITTY_LOCAL/kitty.conf

# quick access terminal
installPreferencesSymlink $PREFERENCES_KITTY_CONFIG/quick-access-terminal.conf $PREFERENCES_KITTY_LOCAL/quick-access-terminal.conf


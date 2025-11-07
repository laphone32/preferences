#!/usr/bin/env bash

PREFERENCES_VSCODE=$PREFERENCES_DIR/vscode
PREFERENCES_VSCODE_CONFIG=$PREFERENCES_VSCODE/config
PREFERENCES_WORKSPACE_VSCODE="$(workspace vscode)"

# os specific
case $PREFERENCES_OS in
    'Darwin')
        PREFERENCES_VSCODE_LOCAL="$HOME/Library/Application Support/Code/User"
        ;;
    'Linux')
        PREFERENCES_VSCODE_LOCAL="$HOME/.config/Code/User"
        ;;
    *)
        ;;
esac

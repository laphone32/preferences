#!/usr/bin/env bash

source $PREFERENCES_DIR/vscode/common.sh

mkdir -p $PREFERENCES_VSCODE_LOCAL
mkdir -p $PREFERENCES_WORKSPACE_VSCODE

# settings.json
DEFAULT_SHELL=$(which bash) envsubst '$DEFAULT_SHELL' < $PREFERENCES_VSCODE_CONFIG/settings.json.template > $PREFERENCES_WORKSPACE_VSCODE/settings.json
ln -sf "$PREFERENCES_WORKSPACE_VSCODE/settings.json" "$PREFERENCES_VSCODE_LOCAL/settings.json"

# keybindings.json
ln -sf "$PREFERENCES_VSCODE_CONFIG/keybindings.json" "$PREFERENCES_VSCODE_LOCAL/keybindings.json"

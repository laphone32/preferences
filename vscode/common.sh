#!/usr/bin/env bash

PREFERENCES_VSCODE=$PREFERENCES_DIR/vscode
PREFERENCES_VSCODE_CONFIG=$PREFERENCES_VSCODE/config
PREFERENCES_WORKSPACE_VSCODE="$(workspace vscode)"

# Load pre-linked os-specific environment if present
[ -f "$PREFERENCES_WORKSPACE_VSCODE/os.env" ] && source "$PREFERENCES_WORKSPACE_VSCODE/os.env"

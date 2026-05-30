#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/antigravity/common.sh

# Ensure ~/.local/bin is in PATH for the current shell execution
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install agy CLI if not already present
if ! command -v agy &> /dev/null; then
    bash "$PREFERENCES_DIR/antigravity/fetchAntigravity.sh"
else
    echo "✓ agy CLI is already installed"
fi

installPreferencesDir $PREFERENCES_ANTIGRAVITY_LOCAL
installPreferencesDir $PREFERENCES_WORKSPACE_ANTIGRAVITY

# Link config if present
PREFERENCES_ANTIGRAVITY_CONFIG="$PREFERENCES_ANTIGRAVITY/config"
if [ -d "$PREFERENCES_ANTIGRAVITY_CONFIG" ]; then
    for conf in "$PREFERENCES_ANTIGRAVITY_CONFIG"/*.conf; do
        [ -f "$conf" ] && installPreferencesSymlink "$conf" "$PREFERENCES_ANTIGRAVITY_LOCAL/$(basename "$conf")"
    done
fi

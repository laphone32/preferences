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

installPreferencesDir $PREFERENCES_WORKSPACE_ANTIGRAVITY
installPreferencesDir $PREFERENCES_ANTIGRAVITY_GLOBAL_CONFIG

# Link settings.json if present
if [ -f "$PREFERENCES_ANTIGRAVITY/config/settings.json" ]; then
    installPreferencesSymlink "$PREFERENCES_ANTIGRAVITY/config/settings.json" "$PREFERENCES_ANTIGRAVITY_GLOBAL_CONFIG/settings.json"
fi

# Link config if present
if [ -d "$PREFERENCES_ANTIGRAVITY/config" ]; then
    installPreferencesSymlink "$PREFERENCES_ANTIGRAVITY/config" "$PREFERENCES_ANTIGRAVITY_LOCAL"
fi

# Link portable skills if present
if [ -d "$PREFERENCES_ANTIGRAVITY/skills" ]; then
    installPreferencesSymlink "$PREFERENCES_ANTIGRAVITY/skills" "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS"
fi

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

# Ensure global skills target is a real directory (remove top-level symlink if present)
if [ -L "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS" ]; then
    rm -f "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS"
fi
installPreferencesDir "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS"

# Link portable skills subdirectories individually
if [ -d "$PREFERENCES_ANTIGRAVITY/skills" ]; then
    for skill_path in "$PREFERENCES_ANTIGRAVITY/skills"/*; do
        if [ -d "$skill_path" ]; then
            skill_name="$(basename "$skill_path")"
            installPreferencesSymlink "$skill_path" "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS/$skill_name"
        fi
    done
fi

# Link cron task if present
if [ -f "$PREFERENCES_ANTIGRAVITY/cron.sh" ]; then
    installPreferencesSymlink "$PREFERENCES_ANTIGRAVITY/cron.sh" "$PREFERENCES_WORKSPACE_ANTIGRAVITY/cron.sh"
fi

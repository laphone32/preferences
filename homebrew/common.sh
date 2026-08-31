#!/usr/bin/env bash
# File: homebrew/common.sh

PREFERENCES_WORKSPACE_HOMEBREW="$(workspace homebrew)"
PREFERENCES_HOMEBREW_ENV="$PREFERENCES_WORKSPACE_HOMEBREW/brew_env.sh"

function ensureBrewPath {
    if ! command -v brew &>/dev/null; then
        for candidate in "/opt/homebrew/bin" "/usr/local/bin" "/home/linuxbrew/.linuxbrew/bin" "$HOME/.linuxbrew/bin"; do
            if [ -f "$candidate/brew" ]; then
                export PATH="$candidate:$PATH"
                break
            fi
        done
    fi
}

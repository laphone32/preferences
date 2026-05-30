#!/usr/bin/env bash

if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi

source $PREFERENCES_DIR/antigravity/common.sh

# Ensure ~/.local/bin is in PATH for the current shell execution
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Detect OS if not already set
if [ -z "$PREFERENCES_OS" ]; then
    if [ -f "$PREFERENCES_DIR/util/environment.sh" ]; then
        source "$PREFERENCES_DIR/util/environment.sh"
    else
        case $OSTYPE in
            'darwin'*) PREFERENCES_OS='Darwin' ;;
            'linux'*) PREFERENCES_OS='Linux' ;;
            *) PREFERENCES_OS='Windows' ;;
        esac
    fi
fi

# Install agy CLI if not already present
if ! command -v agy &> /dev/null; then
    bash "$PREFERENCES_DIR/antigravity/fetchAntigravity.sh"
else
    echo "✓ agy CLI is already installed"
fi

mkdir -p $PREFERENCES_ANTIGRAVITY_LOCAL
mkdir -p $PREFERENCES_WORKSPACE_ANTIGRAVITY

# Link config if present
PREFERENCES_ANTIGRAVITY_CONFIG="$PREFERENCES_ANTIGRAVITY/config"
if [ -d "$PREFERENCES_ANTIGRAVITY_CONFIG" ]; then
    for conf in "$PREFERENCES_ANTIGRAVITY_CONFIG"/*.conf; do
        [ -f "$conf" ] && ln -sf "$conf" "$PREFERENCES_ANTIGRAVITY_LOCAL/$(basename "$conf")"
    done
fi

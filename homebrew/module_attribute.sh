#!/usr/bin/env bash
# File: homebrew/module_attribute.sh

source "$PREFERENCES_DIR/homebrew/common.sh"

function module_get_name() {
    echo "homebrew"
}

function module_is_available() {
    ensureBrewPath
    requireOs 'Darwin' || command -v brew &>/dev/null
}

function module_required_fallback() {
    ensureBrewPath
    if [ "$PREFERENCES_OS" == "Darwin" ] && ! command -v brew &>/dev/null; then
        echo "🍺 Homebrew not found. Bootstrapping Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        ensureBrewPath
    fi
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/homebrew}"
    source "$PREFERENCES_DIR/homebrew/common.sh"

    ensureBrewPath
    if command -v brew &>/dev/null; then
        echo "🍺 Generating Homebrew shell environment cache..."
        brew shellenv > "$PREFERENCES_HOMEBREW_ENV" 2>/dev/null || true
    fi
}

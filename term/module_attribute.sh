#!/usr/bin/env bash
# File: term/module_attribute.sh

function module_get_name() {
    echo "term"
}


function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/term}"
    source "$PREFERENCES_DIR/term/common.sh" 2>/dev/null || true

    installPreferencesDir "$PREFERENCES_WORKSPACE_TERM/theme"
    installPreferencesDir "$PREFERENCES_WORKSPACE_TERM/font"

    echo "Compiling canonical terminal themes to native OSC..."
    python3 "$modDir/compile/compile_themes.py"

    echo "Compiling platform font scripts..."
    python3 "$modDir/compile/compile_apple_terminal.py"
    python3 "$modDir/compile/compile_gnome_terminal.py"
}

#!/usr/bin/env bash
# File: term/common.sh

if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

sourceShare bash environment.sh 2>/dev/null || source "$PREFERENCES_DIR/bash/share/bash/environment.sh" 2>/dev/null || true
sourceShare bash utils.sh 2>/dev/null || source "$PREFERENCES_DIR/bash/share/bash/utils.sh" 2>/dev/null || true

PREFERENCES_TERM="${PREFERENCES_TERM:-$PREFERENCES_DIR/term}"
PREFERENCES_TERM_COMPILE="${PREFERENCES_TERM_COMPILE:-$PREFERENCES_TERM/compile}"

if declare -f workspace &>/dev/null; then
    PREFERENCES_WORKSPACE_TERM="$(workspace term)"
else
    PREFERENCES_WORKSPACE_TERM="${PREFERENCES_WORKSPACE:-$PREFERENCES_DIR/.workspace}/term"
fi

function ensureTermThemesCompiled() {
    local targetOsc="$PREFERENCES_WORKSPACE_TERM/theme/compiled_osc.sh"
    local targetApple="$PREFERENCES_WORKSPACE_TERM/font/apple_terminal.sh"
    local targetGnome="$PREFERENCES_WORKSPACE_TERM/font/gnome_terminal.sh"
    local themesDir="$PREFERENCES_TERM/theme"

    # Auto-recompile if compiled files are missing OR if any .json file is newer
    if [ ! -f "$targetOsc" ] || [ -n "$(find "$themesDir" -name '*.json' -newer "$targetOsc" 2>/dev/null)" ]; then
        mkdir -p "$(dirname "$targetOsc")"
        python3 "$PREFERENCES_TERM_COMPILE/compile_themes.py" >/dev/null 2>&1 || true
    fi

    if [ ! -f "$targetApple" ] || [ ! -f "$targetGnome" ] || [ -n "$(find "$themesDir" -name '*.json' -newer "$targetApple" 2>/dev/null)" ]; then
        mkdir -p "$PREFERENCES_WORKSPACE_TERM/font"
        python3 "$PREFERENCES_TERM_COMPILE/compile_apple_terminal.py" >/dev/null 2>&1 || true
        python3 "$PREFERENCES_TERM_COMPILE/compile_gnome_terminal.py" >/dev/null 2>&1 || true
    fi
}

#!/usr/bin/env bash
# File: shortcut/common.sh

PREFERENCES_SHORTCUT="$PREFERENCES_DIR/shortcut"
PREFERENCES_WORKSPACE_SHORTCUT="$PREFERENCES_WORKSPACE/shortcut"
PREFERENCES_KEYD="$PREFERENCES_SHORTCUT"
PREFERENCES_WORKSPACE_KEYD="$PREFERENCES_WORKSPACE_SHORTCUT"
PREFERENCES_KEYBINDS_LOCAL="$HOME/.config/keyd"
KEYD_ETC_DIR="/etc/keyd"
GNOME_EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
LIBINPUT_QUIRKS_FILE="/etc/libinput/local-overrides.quirks"

GetKeydBinary() {
    if command -v keyd &> /dev/null; then
        echo "keyd"
    elif command -v keyd.rvaiya &> /dev/null; then
        echo "keyd.rvaiya"
    else
        echo ""
    fi
}

KEYD_BIN=$(GetKeydBinary)

ResetGnomeKeybind() {
    local target_key="$1"
    if ! command -v gsettings &>/dev/null; then
        return
    fi

    # List all gsettings, grep for the target key case-insensitively, and unbind them
    gsettings list-recursively | grep -i "'$target_key'" | while read -r schema key value; do
        # Determine if the value is an array or string by checking if it starts with [
        if [[ "$value" == [* ]]; then
            gsettings set "$schema" "$key" "@as []" 2>/dev/null || gsettings set "$schema" "$key" "['']" 2>/dev/null
        else
            gsettings set "$schema" "$key" "''" 2>/dev/null
        fi
    done
}

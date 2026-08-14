#!/usr/bin/env bash
# File: keyd/uninstall.sh

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source "$PREFERENCES_DIR/keyd/common.sh"

echo "Uninstalling Centralized Keyd module..."

# Disable GNOME extension
if command -v gnome-extensions &> /dev/null; then
    gnome-extensions disable keyd 2>/dev/null || true
fi

# Remove system-level config
if [ -d "$KEYD_ETC_DIR" ] && [ -L "$KEYD_ETC_DIR/default.conf" ]; then
    echo "Removing $KEYD_ETC_DIR/default.conf..."
    sudo rm -f "$KEYD_ETC_DIR/default.conf"

    if [ -n "$KEYD_BIN" ]; then
        sudo "$KEYD_BIN" reload 2>/dev/null || true
    fi
fi

# We don't need to manually remove symlinks in ~/.config or ~/.local/share
# because the global uninstaller handles purging managed workspaces and symlinks.

echo "Keyd module uninstallation complete!"

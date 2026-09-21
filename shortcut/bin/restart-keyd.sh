#!/usr/bin/env bash
# File: shortcut/bin/restart-keyd.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source common variables
source "$DIR/common.sh"
source "$DIR/../common.sh" 2>/dev/null || true # Source root common.sh if needed

echo "Compiling keybinds.json..."
python3 "$DIR/bin/compile-keybinds.py" "$DIR/keybinds.json" || {
    echo "ERROR: Compilation failed. Aborting restart."
    exit 1
}

# Ensure destination directories exist
sudo mkdir -p /etc/keyd
mkdir -p ~/.config/keyd

local_workspace="${PREFERENCES_WORKSPACE_SHORTCUT:-$DIR/../.workspace/shortcut}"

# Symlink generated configs to system locations
sudo ln -sf "$local_workspace/default.conf" /etc/keyd/default.conf
ln -sf "$local_workspace/app.conf" ~/.config/keyd/app.conf

echo "Reloading keyd configuration..."
if [ -z "$KEYD_BIN" ]; then
    echo "ERROR: KEYD_BIN is not set. Is keyd installed?"
    exit 1
fi

sudo "$KEYD_BIN" reload || { echo "ERROR: Failed to reload keyd"; exit 1; }
echo "keyd configuration reloaded."

# Source environment and systemd utilities
source "$DIR/../bootstrap.sh" 2>/dev/null || true

if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ] && command -v gnome-extensions &> /dev/null; then
    echo "Restarting keyd GNOME extension..."

    # Ensure the systemd service doesn't conflict with GNOME extension
    if isPreferencesSystemdServiceActive "keyd-application-mapper"; then
        stopPreferencesSystemdService "keyd-application-mapper"
    fi

    gnome-extensions disable keyd 2>/dev/null

    # Wait for the extension to cleanly disable and the mapper to die
    sleep 2
    killall keyd-application-mapper 2>/dev/null

    gnome-extensions enable keyd
    sleep 2

    # Verify extension state
    EXT_STATE=$(gnome-extensions show keyd | grep "State:" | awk '{print $2}')
    if [ "$EXT_STATE" != "ACTIVE" ]; then
        echo "ERROR: GNOME extension failed to activate. Current state: $EXT_STATE"
        exit 1
    fi
    echo "GNOME extension is ACTIVE."

    # Verify mapper is running
    if ! pgrep -f keyd-application-mapper > /dev/null; then
        echo "ERROR: keyd-application-mapper failed to launch!"
        exit 1
    fi
    echo "keyd-application-mapper is running."
else
    echo "Restarting keyd-application-mapper systemd service for DE: ${PREFERENCES_DESKTOP_ENVIRONMENT:-unknown}..."

    killall keyd-application-mapper 2>/dev/null

    # Reload systemd and start the service
    enablePreferencesSystemdService "keyd-application-mapper" || {
        echo "ERROR: Failed to start keyd-application-mapper via systemd!"
        exit 1
    }

    # Verify mapper is running
    if ! isPreferencesSystemdServiceActive "keyd-application-mapper"; then
        echo "ERROR: keyd-application-mapper systemd service is not active!"
        exit 1
    fi
    echo "keyd-application-mapper systemd service is ACTIVE and running."
fi

echo "Restart completed successfully!"

#!/usr/bin/env bash

# Sourcing this file inside preferences-cron-runner requires 'return' instead of 'exit'
# to prevent terminating the main cron runner process.

if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi

source "$PREFERENCES_DIR/kitty/common.sh"

function send_kitty_update_notification {
    local version="$1"
    local title="Preferences Update"
    local message="Kitty terminal has been updated to v$version via preferences cron task"

    if [ "$PREFERENCES_OS" == "Darwin" ]; then
        osascript -e "display notification \"$message\" with title \"$title\""
    elif [ "$PREFERENCES_OS" == "Linux" ]; then
        if command -v notify-send &>/dev/null; then
            # Ensure DBUS and DISPLAY are configured for desktop notifications in cron context
            if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
                export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
            fi
            export DISPLAY="${DISPLAY:-:0}"
            notify-send "$title" "$message" || echo "ℹ Desktop notification sent, but notify-send returned non-zero exit code."
        else
            echo "ℹ notify-send is not installed. Skipping desktop notification."
        fi
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐈 Checking for Kitty Terminal updates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Check if Kitty is installed and managed by the fallback
if ! command -v kitty &> /dev/null; then
    echo "Kitty terminal is not installed. Skipping update."
    return 0
fi

KITTY_BIN_PATH="$(command -v kitty)"
if [[ "$KITTY_BIN_PATH" != "$HOME/.local/bin/kitty" ]] && [[ "$KITTY_BIN_PATH" != *".local/kitty.app"* ]]; then
    echo "✓ Kitty terminal is managed by package manager ($KITTY_BIN_PATH). Deferring updates."
    return 0
fi

# 2. If Kitty is installed, check for updates
CURRENT_VERSION=$(kitty --version 2>/dev/null | cut -d' ' -f2)
if [ -z "$CURRENT_VERSION" ]; then
    echo "⚠ Error: Unable to determine currently installed Kitty version."
    return 0
fi

LATEST_TAG=$(githubLatestRelease kovidgoyal kitty 2>/dev/null)
if [ -z "$LATEST_TAG" ]; then
    echo "⚠ Warning: Failed to fetch the latest Kitty release tag from GitHub (network offline?)."
    return 0
fi

LATEST_VERSION=${LATEST_TAG#v}

echo "Installed version: $CURRENT_VERSION"
echo "Latest version:    $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "📥 A new version is available! Updating Kitty from v$CURRENT_VERSION to v$LATEST_VERSION..."
    
    if curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin >/dev/null 2>&1; then
        # Re-verify update success
        VERIFIED_VERSION=$(kitty --version 2>/dev/null | cut -d' ' -f2)
        if [ "$VERIFIED_VERSION" = "$LATEST_VERSION" ]; then
            echo "✓ Successfully updated Kitty terminal to version $LATEST_VERSION."
            send_kitty_update_notification "$LATEST_VERSION"
        else
            echo "⚠ Warning: Upgrade script completed but version reported is still $VERIFIED_VERSION."
        fi
    else
        echo "⚠ Error: Failed to update Kitty terminal."
    fi
else
    echo "✓ Kitty terminal is already up to date (version $CURRENT_VERSION)."
fi

echo ""

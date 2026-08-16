#!/usr/bin/env bash
# File: util/manifest.sh

[[ "${_PREFERENCES_UTIL_MANIFEST_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_MANIFEST_SOURCED=yes

# Global Manifest Path
PREFERENCES_INSTALL_MANIFEST="$PREFERENCES_WORKSPACE/.install_manifest.log"

# Action Constants
PREFERENCES_INSTALL_ACTION_SYMLINK="Symlink"
PREFERENCES_INSTALL_ACTION_SUDO_SYMLINK="SudoSymlink"
PREFERENCES_INSTALL_ACTION_SECTION="Section"
PREFERENCES_INSTALL_ACTION_SUDO_SECTION="SudoSection"
PREFERENCES_INSTALL_ACTION_DIR="Dir"
PREFERENCES_INSTALL_ACTION_SYSTEMD_USER_SERVICE="SystemdUserService"
# Deprecated: Kept for backwards compatibility with existing manifests; clean up in the future
PREFERENCES_INSTALL_ACTION_SYSTEMD_USER_TIMER="SystemdUserTimer"
PREFERENCES_INSTALL_ACTION_LAUNCH_AGENT="LaunchAgent"
PREFERENCES_INSTALL_ACTION_CRON="Cron"
PREFERENCES_INSTALL_ACTION_FONT_DIR="FontDir"
PREFERENCES_INSTALL_ACTION_GNOME_EXTENSION="GnomeExtension"

# Initialize manifest file if it doesn't exist
function initManifest {
    mkdir -p "$(dirname "$PREFERENCES_INSTALL_MANIFEST")"
    touch "$PREFERENCES_INSTALL_MANIFEST"
}

# Append action to transaction manifest
function appendManifest {
    local actionType=$1
    shift
    local args=("$@")
    
    initManifest
    # Join arguments with pipe symbol '|'
    local IFS='|'
    echo "$actionType|${args[*]}" >> "$PREFERENCES_INSTALL_MANIFEST"
}

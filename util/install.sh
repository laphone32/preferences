#!/usr/bin/env bash
# File: util/install.sh

[[ "${_PREFERENCES_UTIL_INSTALL_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_INSTALL_SOURCED=yes

# Global Manifest Path
PREFERENCES_INSTALL_MANIFEST="$PREFERENCES_WORKSPACE/.install_manifest.log"

# Action Constants
PREFERENCES_INSTALL_ACTION_SYMLINK="Symlink"
PREFERENCES_INSTALL_ACTION_SUDO_SYMLINK="SudoSymlink"
PREFERENCES_INSTALL_ACTION_SECTION="Section"
PREFERENCES_INSTALL_ACTION_DIR="Dir"
PREFERENCES_INSTALL_ACTION_SYSTEMD_USER_TIMER="SystemdUserTimer"
PREFERENCES_INSTALL_ACTION_LAUNCH_AGENT="LaunchAgent"
PREFERENCES_INSTALL_ACTION_CRON="Cron"
PREFERENCES_INSTALL_ACTION_FONT_DIR="FontDir"

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

# =====================================================================
# Symmetric Installation and Uninstallation (Undo) Pairs
# =====================================================================

# --- 1. Symlink (User-level) ---
function installPreferencesSymlink {
    local source=$1
    local target=$2
    
    ln -sf "$source" "$target"
    appendManifest "$PREFERENCES_INSTALL_ACTION_SYMLINK" "$target"
}

function undoPreferencesSymlink {
    local target=$1
    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        rm "$target"
    fi
}

# --- 2. Sudo Symlink (System-level settings like logind.conf) ---
# NOTE: We use a dedicated function rather than running "sudo installPreferencesSymlink"
# because bash functions exist only in the current shell process memory. The 'sudo' 
# binary cannot call bash functions directly without spawning verbose, complex subshells.
# Prepending 'sudo' to the commands inside this helper keeps the script clean and native.
function installPreferencesSudoSymlink {
    local source=$1
    local target=$2
    
    sudo mkdir -p "$(dirname "$target")"
    sudo ln -sf "$source" "$target"
    appendManifest "$PREFERENCES_INSTALL_ACTION_SUDO_SYMLINK" "$target"
}

function undoPreferencesSudoSymlink {
    local target=$1
    if [ -L "$target" ] || [ -f "$target" ]; then
        echo "Removing sudo-created symlink/file: $target"
        sudo rm -f "$target"
    fi
}

# --- 3. Text File Section ---
function installPreferencesSection {
    local filePath=$1
    local sectionName=$2
    local content=$3
    
    updateOrInsertSection "$filePath" "$sectionName" "$content"
    appendManifest "$PREFERENCES_INSTALL_ACTION_SECTION" "$filePath" "$sectionName"
}

function undoPreferencesSection {
    local filePath=$1
    local sectionName=$2
    if [ -f "$filePath" ]; then
        echo "Removing configuration section [$sectionName] from $filePath"
        sed -i "/### $sectionName ###/,/### end of $sectionName ###/d" "$filePath"
    fi
}

# --- 4. Directory Creation ---
function installPreferencesDir {
    local dirPath=$1
    
    mkdir -p "$dirPath"
    appendManifest "$PREFERENCES_INSTALL_ACTION_DIR" "$dirPath"
}

function undoPreferencesDir {
    local dirPath=$1
    if [ -d "$dirPath" ]; then
        # Safe check: only delete if it's empty, avoiding deleting general folders like ~/.config
        echo "Removing directory if empty: $dirPath"
        rmdir "$dirPath" 2>/dev/null || true
    fi
}

# --- 5. Systemd User Timer (Linux user schedules/updates) ---
function installPreferencesSystemdUserTimer {
    local timerName=$1
    local serviceTemplate=$2
    local timerTemplate=$3
    
    local userSystemdDir="$HOME/.config/systemd/user"
    mkdir -p "$userSystemdDir"
    
    local targetService="$userSystemdDir/$timerName.service"
    local targetTimer="$userSystemdDir/$timerName.timer"
    
    # Deploy files: replace placeholders inside service unit using envsubst
    PREFERENCES_DIR=$PREFERENCES_DIR envsubst '$PREFERENCES_DIR' < "$serviceTemplate" > "$targetService"
    cp "$timerTemplate" "$targetTimer"
    
    # Reload daemon, enable and activate timer
    systemctl --user daemon-reload
    systemctl --user enable --now "$timerName.timer"
    
    appendManifest "$PREFERENCES_INSTALL_ACTION_SYSTEMD_USER_TIMER" "$timerName" "$targetService" "$targetTimer"
}

function undoPreferencesSystemdUserTimer {
    local timerName=$1
    local targetService=$2
    local targetTimer=$3
    
    echo "Disabling and removing Systemd User Timer: $timerName"
    systemctl --user disable --now "$timerName.timer" 2>/dev/null || true
    rm -f "$targetService" "$targetTimer" 2>/dev/null || true
    systemctl --user daemon-reload
}

# --- 6. LaunchAgent (macOS user schedules/updates) ---
function installPreferencesLaunchAgent {
    local label=$1
    local plistTemplate=$2
    
    local targetDir="$HOME/Library/LaunchAgents"
    mkdir -p "$targetDir"
    local targetPlist="$targetDir/$label.plist"
    
    # Stop and unload existing plist if loaded
    launchctl unload "$targetPlist" &>/dev/null || true
    
    # Deploy plist with absolute paths replaced using envsubst
    PREFERENCES_DIR=$PREFERENCES_DIR envsubst '$PREFERENCES_DIR' < "$plistTemplate" > "$targetPlist"
    
    # Load launch agent
    launchctl load "$targetPlist"
    
    appendManifest "$PREFERENCES_INSTALL_ACTION_LAUNCH_AGENT" "$label" "$targetPlist"
}

function undoPreferencesLaunchAgent {
    local label=$1
    local targetPlist=$2
    
    echo "Unloading and removing macOS LaunchAgent: $label"
    launchctl unload "$targetPlist" 2>/dev/null || true
    rm -f "$targetPlist" 2>/dev/null || true
}

# --- 7. POSIX Cron Job (Fallback schedules) ---
function installPreferencesCron {
    local identifier=$1
    local cronCmd=$2
    
    # Get current crontab, excluding any existing matching entries
    local current_cron=""
    current_cron=$(crontab -l 2>/dev/null | grep -v "$identifier" || true)
    
    # Update crontab
    (echo "$current_cron"; echo "$cronCmd") | crontab -
    
    appendManifest "$PREFERENCES_INSTALL_ACTION_CRON" "$identifier"
}

function undoPreferencesCron {
    local identifier=$1
    echo "Removing cron jobs matching: $identifier"
    crontab -l 2>/dev/null | grep -v "$identifier" | crontab - 2>/dev/null || true
}

# --- 8. Font Directory (Nerd Fonts target directory) ---
function installPreferencesFontDir {
    local dirPath=$1
    
    mkdir -p "$dirPath"
    appendManifest "$PREFERENCES_INSTALL_ACTION_FONT_DIR" "$dirPath"
}

function undoPreferencesFontDir {
    local dirPath=$1
    if [ -d "$dirPath" ]; then
        # Double check to ensure we only recursively delete under the custom preferences name prefix
        if [[ "$dirPath" == *"preferences_installed_font_"* ]]; then
            echo "Removing preferences-installed font folder: $dirPath"
            rm -rf "$dirPath"
        fi
    fi
}


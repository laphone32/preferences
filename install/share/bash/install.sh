#!/usr/bin/env bash
# File: install/share/bash/install.sh

[[ "${_PREFERENCES_INSTALL_INSTALL_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_INSTALL_INSTALL_SOURCED=yes

# Load manifest transaction logging and systemd utilities
if declare -f sourceShare &>/dev/null; then
    sourceShare install manifest.sh 2>/dev/null || true
    sourceShare system systemd.sh 2>/dev/null || true
else
    source "${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}/install/share/bash/manifest.sh" 2>/dev/null || true
    source "${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}/system/share/bash/systemd.sh" 2>/dev/null || true
fi

# =====================================================================
# Symmetric Installation and Uninstallation (Undo) Pairs
# =====================================================================

# --- 1. Symlink (User-level) ---
function installPreferencesSymlink {
    local source=$1
    local target=$2

    # Strip trailing slash if present to avoid dereferencing directory symlinks
    target="${target%/}"

    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target" 2>/dev/null || true)
        if [ "$current_target" == "$source" ]; then
            appendManifest "$PREFERENCES_INSTALL_ACTION_SYMLINK" "$target"
            return 0
        fi
        unlink "$target" 2>/dev/null || rm -f "$target"
    elif [ -d "$target" ]; then
        rm -rf "$target"
    elif [ -f "$target" ]; then
        rm -f "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    appendManifest "$PREFERENCES_INSTALL_ACTION_SYMLINK" "$target"
}

function undoPreferencesSymlink {
    local target=$1
    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        unlink "$target" 2>/dev/null || rm -f "$target"
    fi
}

# --- 2. Sudo Symlink (System-level settings like logind.conf) ---
function installPreferencesSudoSymlink {
    local source=$1
    local target=$2
    target="${target%/}"

    # If the symlink already exists and points to the exact same source, skip sudo
    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target" 2>/dev/null || true)
        if [ "$current_target" == "$source" ]; then
            appendManifest "$PREFERENCES_INSTALL_ACTION_SUDO_SYMLINK" "$target"
            return 0
        fi
    fi

    sudo mkdir -p "$(dirname "$target")"
    if [ -L "$target" ]; then
        sudo unlink "$target" 2>/dev/null || sudo rm -f "$target"
    elif [ -d "$target" ]; then
        sudo rm -rf "$target"
    elif [ -f "$target" ]; then
        sudo rm -f "$target"
    fi
    sudo ln -sf "$source" "$target"
    appendManifest "$PREFERENCES_INSTALL_ACTION_SUDO_SYMLINK" "$target"
}

function undoPreferencesSudoSymlink {
    local target=$1
    if [ -L "$target" ]; then
        echo "Removing sudo-created symlink: $target"
        sudo unlink "$target" 2>/dev/null || sudo rm -f "$target"
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
        deleteSection "$filePath" "$sectionName"
    fi
}

# --- 4. Sudo Text File Section ---
function installPreferencesSudoSection {
    local filePath=$1
    local sectionName=$2
    local content=$3

    updateOrInsertSection "$filePath" "$sectionName" "$content" true
    appendManifest "$PREFERENCES_INSTALL_ACTION_SUDO_SECTION" "$filePath" "$sectionName"
}

function undoPreferencesSudoSection {
    local filePath=$1
    local sectionName=$2
    if [ -f "$filePath" ]; then
        echo "Removing sudo configuration section [$sectionName] from $filePath"
        deleteSection "$filePath" "$sectionName" true
    fi
}

# --- 5. Directory Creation ---
function installPreferencesDir {
    local dirPath=$1
    dirPath="${dirPath%/}"

    # Only create and record in manifest if the directory did not exist beforehand
    if [ ! -d "$dirPath" ]; then
        mkdir -p "$dirPath"
        appendManifest "$PREFERENCES_INSTALL_ACTION_DIR" "$dirPath"
    fi
}

function undoPreferencesDir {
    local dirPath=$1
    if [ -d "$dirPath" ]; then
        # Safe check: only delete if it's empty, avoiding deleting general folders
        echo "Removing directory if empty: $dirPath"
        rmdir "$dirPath" 2>/dev/null || true
    fi
}

# --- 5. Systemd User Service & Timer (Linux user background services/schedules) ---
function installPreferencesSystemdUserService {
    local unitName=$1          # e.g., "keyd-application-mapper" or "preferences-update"
    local serviceFile=$2       # Path to already-prepared / substituted .service file
    local timerFile=${3:-""}   # (Optional) Path to .timer file

    # 1. OS & Systemd check
    if ! isPreferencesSystemdUserAvailable; then
        echo "ℹ Skipping systemd service '$unitName' (Systemd user session not available on $PREFERENCES_OS)."
        return 0
    fi

    local userSystemdDir="$HOME/.config/systemd/user"
    mkdir -p "$userSystemdDir"

    # Normalize name with preferences- prefix for consistent administration
    local baseName=$(getPreferencesSystemdUnitBaseName "$unitName")
    local targetService="$userSystemdDir/$baseName.service"
    local targetTimer=""

    # 2. Symlink the prepared service file
    installPreferencesSymlink "$serviceFile" "$targetService"

    # 3. If timer is provided, symlink timer and activate timer only
    if [ -n "$timerFile" ]; then
        targetTimer="$userSystemdDir/$baseName.timer"
        installPreferencesSymlink "$timerFile" "$targetTimer"
        enablePreferencesSystemdTimer "$baseName"
    else
        # Standalone service: activate service directly
        enablePreferencesSystemdService "$baseName"
    fi

    # 4. Append to transaction manifest for uninstall.sh
    appendManifest "$PREFERENCES_INSTALL_ACTION_SYSTEMD_USER_SERVICE" "$baseName" "$targetService" "$targetTimer"
}

function undoPreferencesSystemdUserService {
    local baseName=$1
    local targetService=$2
    local targetTimer=$3

    if [ -n "$targetTimer" ]; then
        echo "Disabling and removing Systemd User Timer: $baseName.timer"
        disablePreferencesSystemdTimer "$baseName"
        rm -f "$targetTimer" 2>/dev/null || true
    else
        echo "Disabling and stopping Systemd User Service: $baseName.service"
        disablePreferencesSystemdService "$baseName"
    fi

    rm -f "$targetService" 2>/dev/null || true
    reloadPreferencesSystemdUserDaemon
}

# Compatibility alias for undoing older manifest entries if present
function undoPreferencesSystemdUserTimer {
    undoPreferencesSystemdUserService "$@"
}

# --- 6. LaunchAgent (macOS user schedules/updates) ---
function installPreferencesLaunchAgent {
    local label=$1
    local plistTemplate=$2

    # OS & Launchctl check
    if [ "$PREFERENCES_OS" != "Darwin" ] || ! command -v launchctl &>/dev/null; then
        echo "ℹ Skipping LaunchAgent '$label' (LaunchAgent not available on $PREFERENCES_OS)."
        return 0
    fi

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

# --- 8. Workspace Cron Task Symlinks ---
function installPreferencesCronTask {
    local sourceScript=$1
    local moduleName=$2
    local taskName=${3:-$(basename "$sourceScript")}

    local targetDir="$(workspace "$moduleName")/cron"
    installPreferencesDir "$targetDir"
    installPreferencesSymlink "$sourceScript" "$targetDir/$taskName"
}

function installPreferencesCronDir {
    local sourceDir=$1
    local moduleName=$2

    if [ -d "$sourceDir" ]; then
        for taskFile in "$sourceDir"/*.sh; do
            if [ -f "$taskFile" ]; then
                local taskName="$(basename "$taskFile")"
                installPreferencesCronTask "$taskFile" "$moduleName" "$taskName"
            fi
        done
    fi
}

# --- 9. Font Directory (Nerd Fonts target directory) ---
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

# --- 10. GNOME Shell Extension ---
function installPreferencesGnomeExtension {
    local sourceDir=$1
    local extensionName=$2
    local extensionsDir="${GNOME_EXTENSIONS_DIR:-$HOME/.local/share/gnome-shell/extensions}"
    local targetDir="$extensionsDir/$extensionName"

    installPreferencesDir "$extensionsDir"
    installPreferencesSymlink "$sourceDir" "$targetDir"

    if command -v gnome-extensions &> /dev/null; then
        gnome-extensions enable "$extensionName" 2>/dev/null || true
    fi

    appendManifest "$PREFERENCES_INSTALL_ACTION_GNOME_EXTENSION" "$extensionName" "$targetDir"
}

function undoPreferencesGnomeExtension {
    local extensionName=$1
    local targetDir=$2

    if command -v gnome-extensions &> /dev/null; then
        echo "Disabling GNOME Extension: $extensionName"
        gnome-extensions disable "$extensionName" 2>/dev/null || true
    fi

    if [ -L "$targetDir" ]; then
        echo "Removing GNOME Extension symlink: $targetDir"
        unlink "$targetDir" 2>/dev/null || rm -f "$targetDir"
    fi
}

# --- 11. Workspace Network Hook Task Symlinks ---
function installPreferencesNetworkHookTask {
    local sourceScript=$1
    local moduleName=$2
    local taskName=${3:-$(basename "$sourceScript")}

    local targetDir="$(workspace "$moduleName")/network-hooks.d"
    installPreferencesDir "$targetDir"
    installPreferencesSymlink "$sourceScript" "$targetDir/$taskName"
}

function installPreferencesNetworkHookDir {
    local sourceDir=$1
    local moduleName=$2

    if [ -d "$sourceDir" ]; then
        for hookFile in "$sourceDir"/*.sh; do
            if [ -f "$hookFile" ]; then
                local hookName="$(basename "$hookFile")"
                installPreferencesNetworkHookTask "$hookFile" "$moduleName" "$hookName"
            fi
        done
    fi
}

# =====================================================================
# Manifest-Driven Uninstallation
# =====================================================================

function uninstallPreferencesManifest {
    if [ ! -f "$PREFERENCES_INSTALL_MANIFEST" ]; then
        echo "No installation manifest found at $PREFERENCES_INSTALL_MANIFEST."
        echo "This project might not have been installed using the wrapper helpers."
        return 1
    fi

    echo "=========================================="
    echo "🧹 Starting Preferences Uninstallation"
    echo "=========================================="

    # Read lines in reverse order (LIFO) and dynamically invoke the corresponding namespaced undo function
    tac "$PREFERENCES_INSTALL_MANIFEST" | while IFS='|' read -r action arg1 arg2 arg3 arg4; do
        undoFunc="undoPreferences${action}"
        if declare -f "$undoFunc" > /dev/null; then
            # Dynamically call the undo function with the logged parameters
            "$undoFunc" "$arg1" "$arg2" "$arg3" "$arg4"
        else
            echo "⚠ Warning: No undo handler found for action '$action' ($undoFunc)"
        fi
    done
}

#!/usr/bin/env bash
# File: util/module.sh

[[ "${_PREFERENCES_UTIL_MODULE_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_MODULE_SOURCED=yes

# =====================================================================
# Configuration & Constants
# =====================================================================

PREFERENCES_MODULE_ATTRIBUTE_FILE="module_attribute.sh"
PREFERENCES_MODULE_MAX_DEPTH=${PREFERENCES_MODULE_MAX_DEPTH:-3}

# =====================================================================
# Scope Isolation & Hook Contracts
# =====================================================================

# Reset function definitions before sourcing any module_attribute.sh.
# Each unset statement is paired with documentation of the hook's contract.
function _resetModuleScope {
    # 1. module_get_name
    #    - Purpose: Return the display / identifier name for the module.
    #    - Output: Echoes name string to stdout.
    #    - Default: Basename of the module directory.
    unset -f module_get_name 2>/dev/null || true

    # 2. module_is_meta
    #    - Purpose: Indicate if this directory is a meta-module containing child submodules.
    #    - Return: 0 (true, is meta) or 1 (false, regular module).
    #    - Default: 1 (not a meta-module).
    unset -f module_is_meta 2>/dev/null || true

    # 3. module_is_available
    #    - Purpose: Check OS, distro, desktop environment, or runtime preconditions.
    #    - Return: 0 (available/eligible) or non-zero (skip module).
    #    - Default: 0 (available on all platforms).
    unset -f module_is_available 2>/dev/null || true

    # 4. module_get_packages
    #    - Purpose: Provide list of required CLI packages.
    #    - Output: Space or newline-separated package names on stdout.
    #    - Default: Empty (no CLI packages required).
    unset -f module_get_packages 2>/dev/null || true

    # 5. module_get_gui_packages
    #    - Purpose: Provide list of required Desktop GUI packages.
    #    - Output: Space or newline-separated package names on stdout.
    #    - Default: Empty (no GUI packages required).
    unset -f module_get_gui_packages 2>/dev/null || true

    # 6. module_required_fallback
    #    - Purpose: Execute custom installation or alias wrapping for missing packages.
    #    - Return: 0 on success, non-zero on failure.
    #    - Default: No action.
    unset -f module_required_fallback 2>/dev/null || true

    # 7. module_install
    #    - Purpose: Execute installation and configuration actions for the module.
    #    - Arguments: $1 = absolute directory path to the module.
    #    - Return: 0 on success.
    #    - Default: No action.
    unset -f module_install 2>/dev/null || true
}

# =====================================================================
# Module Detection & Attributes Loading
# =====================================================================

# Check if a directory qualifies as a module
function isModule {
    local dir="${1%/}"
    [ -f "$dir/$PREFERENCES_MODULE_ATTRIBUTE_FILE" ]
}

# Safely load module attributes after resetting function scope
function loadModuleAttributes {
    local dir="${1%/}"
    _resetModuleScope

    if isModule "$dir"; then
        source "$dir/$PREFERENCES_MODULE_ATTRIBUTE_FILE"
    fi
}

# Combined availability check: Must be a module AND satisfy runtime conditions
function isModuleAvailable {
    local dir="${1%/}"
    if ! isModule "$dir"; then
        return 1
    fi

    loadModuleAttributes "$dir"
    if declare -f module_is_available &>/dev/null; then
        module_is_available
    else
        return 0 # Default: available everywhere
    fi
}

# Check if a module is designated as a meta-module
function isMetaModule {
    local dir="${1%/}"
    if ! isModule "$dir"; then
        return 1
    fi

    loadModuleAttributes "$dir"
    if declare -f module_is_meta &>/dev/null; then
        module_is_meta
    else
        return 1 # Default: not meta
    fi
}

# =====================================================================
# Platform Matching Helpers (For use inside module_is_available)
# =====================================================================

function requireOs {
    for targetOs in "$@"; do
        if [ "$PREFERENCES_OS" == "$targetOs" ]; then
            return 0
        fi
    done
    return 1
}

function requireDistro {
    for targetDistro in "$@"; do
        if [ "$PREFERENCES_DISTRO" == "$targetDistro" ] || [ "$PREFERENCES_DISTRO_LIKE" == "$targetDistro" ]; then
            return 0
        fi
    done
    return 1
}

function requireDesktopEnvironment {
    for targetDe in "$@"; do
        if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "$targetDe" ]; then
            return 0
        fi
    done
    return 1
}

# =====================================================================
# Module Iteration & Traversal
# =====================================================================

function _traverseModules {
    local currentDir="${1%/}"
    local callback=$2
    local currentDepth=$3
    local maxDepth=$4

    [ $currentDepth -gt $maxDepth ] && return 0

    for subDir in "$currentDir"/*/; do
        [ ! -d "$subDir" ] && continue
        subDir="${subDir%/}"

        # Single combined check: must be a module and available in current environment
        if isModuleAvailable "$subDir"; then
            local modName
            if declare -f module_get_name &>/dev/null; then
                modName=$(module_get_name)
            else
                modName=$(basename "$subDir")
            fi

            # Pre-order callback execution: callback "$subDir" "$modName"
            $callback "$subDir" "$modName"

            # Recurse into submodules if designated as meta-module
            if isMetaModule "$subDir"; then
                _traverseModules "$subDir" "$callback" $((currentDepth + 1)) "$maxDepth"
            fi
        fi
    done
}

# General-purpose module visitor (pre-order traversal with recursive meta-module expansion)
function forEachModule {
    local callback=$1
    local rootDir="${2:-$PREFERENCES_DIR}"
    _traverseModules "$rootDir" "$callback" 1 "$PREFERENCES_MODULE_MAX_DEPTH"
}

# Helper for executing an action on specific module files (e.g., 'install.sh', 'bashrc')
function forEachModuleFile {
    local fileName=$1
    local action=$2
    local rootDir="${3:-$PREFERENCES_DIR}"

    _moduleFileRunner() {
        local modDir=$1
        local modName=$2
        local targetFile="$modDir/$fileName"

        if [ -e "$targetFile" ]; then
            $action "$targetFile"
        fi
    }

    forEachModule _moduleFileRunner "$rootDir"
}

# =====================================================================
# Package Collection & Fallback Execution
# =====================================================================

function collectAllModulePackages {
    local envType=${1:-cli} # 'cli' or 'gui'
    local collectedPackages=()

    _collectModulePkgs() {
        local modDir=$1
        loadModuleAttributes "$modDir"
        local pkgs=""
        if [ "$envType" == "gui" ] && declare -f module_get_gui_packages &>/dev/null; then
            pkgs=$(module_get_gui_packages)
        elif declare -f module_get_packages &>/dev/null; then
            pkgs=$(module_get_packages)
        fi

        for p in $pkgs; do
            [ -n "$p" ] && collectedPackages+=("$p")
        done
    }

    forEachModule _collectModulePkgs
    echo "${collectedPackages[@]}"
}

function runAllModuleFallbacks {
    _execModuleFallback() {
        local modDir=$1
        loadModuleAttributes "$modDir"
        if declare -f module_required_fallback &>/dev/null; then
            module_required_fallback
        fi
    }
    forEachModule _execModuleFallback
}

# =====================================================================
# Module Installation Execution
# =====================================================================

function installModule {
    local dir="${1%/}"
    if isModuleAvailable "$dir"; then
        loadModuleAttributes "$dir"
        if declare -f module_install &>/dev/null; then
            local modName
            if declare -f module_get_name &>/dev/null; then
                modName=$(module_get_name)
            else
                modName=$(basename "$dir")
            fi
            echo "📦 Installing module [$modName]..."
            installPreferencesDir "$(workspace "$modName")"
            installPreferencesDir "$(workspace "$modName")/cron"
            module_install "$dir"
        fi
    else
        echo "ℹ Skipping module at $dir (not a valid/available module in current environment)."
    fi
}

function installAllModules {
    local rootDir="${1:-$PREFERENCES_DIR}"

    _execModuleInstall() {
        local modDir="${1%/}"
        local modName=$2

        installModule "$modDir"
    }

    forEachModule _execModuleInstall "$rootDir"
}



#!/usr/bin/env bash
# File: util/systemd.sh

[[ "${_PREFERENCES_UTIL_SYSTEMD_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_SYSTEMD_SOURCED=yes

# Standard service prefix for all preferences-managed systemd units
PREFERENCES_INSTALL_SYSTEMD_SERVICE_PREFIX="preferences-"

# =====================================================================
# Systemd Availability Checks
# =====================================================================

function isPreferencesSystemdUserAvailable {
    [ "$PREFERENCES_OS" == "Linux" ] && command -v systemctl &>/dev/null && systemctl --user &>/dev/null
}

# =====================================================================
# Systemd User Unit Name Normalization
# =====================================================================

function getPreferencesSystemdUnitBaseName {
    local unitName=$1
    local servicePrefix="${PREFERENCES_INSTALL_SYSTEMD_SERVICE_PREFIX:-preferences-}"
    local rawName="${unitName%.service}"
    rawName="${rawName%.timer}"
    if [[ "$rawName" != "$servicePrefix"* ]]; then
        echo "${servicePrefix}${rawName}"
    else
        echo "$rawName"
    fi
}

function getPreferencesSystemdServiceName {
    local unitName=$1
    local baseName=$(getPreferencesSystemdUnitBaseName "$unitName")
    echo "${baseName}.service"
}

function getPreferencesSystemdTimerName {
    local unitName=$1
    local baseName=$(getPreferencesSystemdUnitBaseName "$unitName")
    echo "${baseName}.timer"
}

# =====================================================================
# Systemd User Service Runtime Management Helpers
# =====================================================================

function reloadPreferencesSystemdUserDaemon {
    isPreferencesSystemdUserAvailable || return 0
    systemctl --user daemon-reload 2>/dev/null || true
}

function isPreferencesSystemdServiceActive {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user is-active --quiet "$serviceName" 2>/dev/null
}

function startPreferencesSystemdService {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user daemon-reload
    systemctl --user start "$serviceName"
}

function stopPreferencesSystemdService {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 0
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user stop "$serviceName" 2>/dev/null || true
}

function restartPreferencesSystemdService {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user daemon-reload
    systemctl --user restart "$serviceName"
}

function reloadPreferencesSystemdService {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user daemon-reload
    systemctl --user reload-or-restart "$serviceName"
}

function enablePreferencesSystemdService {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user daemon-reload
    systemctl --user enable --now "$serviceName"
}

function disablePreferencesSystemdService {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 0
    local serviceName=$(getPreferencesSystemdServiceName "$unitName")
    systemctl --user disable --now "$serviceName" 2>/dev/null || true
}

# =====================================================================
# Systemd User Timer Runtime Management Helpers
# =====================================================================

function isPreferencesSystemdTimerActive {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local timerName=$(getPreferencesSystemdTimerName "$unitName")
    systemctl --user is-active --quiet "$timerName" 2>/dev/null
}

function enablePreferencesSystemdTimer {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 1
    local timerName=$(getPreferencesSystemdTimerName "$unitName")
    systemctl --user daemon-reload
    systemctl --user enable --now "$timerName"
}

function disablePreferencesSystemdTimer {
    local unitName=$1
    isPreferencesSystemdUserAvailable || return 0
    local timerName=$(getPreferencesSystemdTimerName "$unitName")
    systemctl --user disable --now "$timerName" 2>/dev/null || true
}

# =====================================================================
# System-Level (Root) Systemd Helpers
# =====================================================================

function enablePreferencesSystemdSystemService {
    local serviceName=$1
    [ "$PREFERENCES_OS" == "Linux" ] && command -v systemctl &>/dev/null || return 1
    sudo systemctl daemon-reload 2>/dev/null || true
    sudo systemctl enable --now "$serviceName" 2>/dev/null || true
}

function restartPreferencesSystemdSystemService {
    local serviceName=$1
    [ "$PREFERENCES_OS" == "Linux" ] && command -v systemctl &>/dev/null || return 1
    sudo systemctl daemon-reload 2>/dev/null || true
    sudo systemctl restart "$serviceName" 2>/dev/null || true
}

#!/usr/bin/env bash
# File: system/module_attribute.sh

function module_get_name() {
    echo "system"
}

function module_is_available() {
    requireOs "Linux" || return 1
    [ "$(ps --no-headers -o comm 1 2>/dev/null)" == "systemd" ]
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/system}"

    echo "Installing system preferences settings"
    "$modDir/disable_silent_fan_mode.sh" 2>/dev/null || true
    "$modDir/max_battery_limit.sh" 2>/dev/null || true

    # preferences settings
    installPreferencesSudoSymlink "$modDir/logind.conf" /etc/systemd/logind.conf.d/preferences.conf
}

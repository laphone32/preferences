#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"

PREFERENCES_SYSTEM=$PREFERENCES_DIR/system
running=$(ps --no-headers -o comm 1)

if [ $? -eq 0 ] && [ "$running" == "systemd" ]; then
    echo "Installing system preferences settings"

    #$PREFERENCES_SYSTEM/disable_turbo_boost.sh
    $PREFERENCES_SYSTEM/disable_silent_fan_mode.sh
    $PREFERENCES_SYSTEM/max_battery_limit.sh

    # preferences settings
    installPreferencesSudoSymlink "$PREFERENCES_SYSTEM/logind.conf" /etc/systemd/logind.conf.d/preferences.conf
fi

#!/usr/bin/env bash

PREFERENCES_SYSTEMD=$PREFERENCES_DIR/systemd
running=$(ps --no-headers -o comm 1)

if [ $? -eq 0 ] && [ $running == 'systemd' ]; then
    echo "Installing systemd preferencs settings"

    #$PREFERENCES_SYSTEMD/disable_turbo_boost.sh
    $PREFERENCES_SYSTEMD/disable_silent_fan_mode.sh
    $PREFERENCES_SYSTEMD/max_battery_limit.sh

    # preferences settings
    sudo mkdir -p /etc/systemd/logind.conf.d/
    sudo ln -sf $PREFERENCES_SYSTEMD/logind.conf /etc/systemd/logind.conf.d/preferences.conf
fi




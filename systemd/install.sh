#!/usr/bin/env bash

PREFERENCES_SYSTEMD=$PREFERENCES_DIR/systemd

$PREFERENCES_SYSTEMD/disable_turbo_boost.sh
$PREFERENCES_SYSTEMD/disable_silent_fan_mode.sh
$PREFERENCES_SYSTEMD/max_battery_limit.sh



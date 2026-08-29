#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../bootstrap.sh" 2>/dev/null || true

DRIVER1='/sys/class/power_supply/CMB0/charge_control_end_threshold'
DRIVER2='/sys/devices/platform/lg-laptop/battery_care_limit'

if [ -f "$DRIVER1" ]; then
    DRIVER=$DRIVER1
else
    DRIVER=$DRIVER2
fi

CONFIG='/etc/tmpfiles.d/max_battery_limit.conf'

if [ -f "$DRIVER" ]; then
    installPreferencesSudoSection "$CONFIG" "preferences-max-battery-limit" "w $DRIVER - - - - 80"
fi

#!/usr/bin/env bash

DRIVER='/sys/class/power_supply/CMB0/charge_control_end_threshold'
CONFIG='/etc/tmpfiles.d/max_battery_limit.conf'

if [ -f $DRIVER ]; then
    echo "w $DRIVER - - - - 80" | sudo tee "$CONFIG"
fi

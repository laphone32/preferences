#!/sur/bin/env bash

DRIVER='/sys/devices/platform/lg-laptop/fan_mode'
CONFIG='/etc/tmpfiles.d/disable_silent_fan_mode.conf'

if [ -f $DRIVER ]; then
    echo "w $DRIVER - - - - 1" | sudo tee "$CONFIG"
fi

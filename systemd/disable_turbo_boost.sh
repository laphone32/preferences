#!/bin/bash

DRIVER='/sys/devices/system/cpu/intel_pstate/no_turbo'
CONFIG='/etc/tmpfiles.d/disable_turbo_boost.conf'

if [ -f $DRIVER ]; then
    echo "w $DRIVER - - - - 1" | sudo tee "$CONFIG"
fi

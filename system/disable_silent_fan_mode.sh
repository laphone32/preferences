#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh" 2>/dev/null || true

DRIVER='/sys/devices/platform/lg-laptop/fan_mode'
CONFIG='/etc/tmpfiles.d/disable_silent_fan_mode.conf'

if [ -f "$DRIVER" ]; then
    installPreferencesSudoSection "$CONFIG" "preferences-disable-silent-fan-mode" "w $DRIVER - - - - 1"
fi

#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh" 2>/dev/null || true

DRIVER='/sys/devices/system/cpu/intel_pstate/no_turbo'
CONFIG='/etc/tmpfiles.d/disable_turbo_boost.conf'

if [ -f "$DRIVER" ]; then
    installPreferencesSudoSection "$CONFIG" "preferences-disable-turbo-boost" "w $DRIVER - - - - 1"
fi

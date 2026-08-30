#!/usr/bin/env bash
# File: network/network-hooks.d/01_sync_timezone.sh

set -euo pipefail

try_fetch_tz() {
    local url=$1
    local resp
    resp=$(curl -fsSL --connect-timeout 3 --max-time 5 "$url" 2>/dev/null) || return 1

    # Format A: Key-value formatted response (e.g. worldtimeapi: "timezone: America/New_York")
    if [[ "$resp" =~ timezone:[[:space:]]*([A-Za-z_]+/[A-Za-z_]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    # Format B: Direct timezone string (e.g. ipapi.co, ip-api.com: "America/New_York")
    elif [[ "$resp" =~ ^[A-Za-z_]+/[A-Za-z_]+$ ]]; then
        echo "$resp"
        return 0
    fi

    return 1
}

fetch_timezone() {
    local endpoints=(
        "https://ipapi.co/timezone"
        "http://ip-api.com/line?fields=timezone"
        "https://worldtimeapi.org/api/ip.txt"
    )

    for endpoint in "${endpoints[@]}"; do
        local tz
        if tz=$(try_fetch_tz "$endpoint") && [[ -n "$tz" ]]; then
            echo "$tz"
            return 0
        fi
    done

    return 1
}

# 1. Obtain timezone from network endpoints
if ! TARGET_TZ=$(fetch_timezone); then
    echo "No valid timezone response from geo-ip endpoints (offline or throttled)." >&2
    exit 0
fi

# 2. Check current system timezone
CURRENT_TZ=$(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || true)

# 3. Apply change only when needed
if [[ "$CURRENT_TZ" == "$TARGET_TZ" ]]; then
    echo "Timezone already synchronized: $CURRENT_TZ"
    exit 0
fi

echo "Updating timezone: $CURRENT_TZ -> $TARGET_TZ"
timedatectl set-timezone "$TARGET_TZ"

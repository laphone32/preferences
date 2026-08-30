#!/usr/bin/env bash
# File: network/module_attribute.sh

function module_get_name() {
    echo "network"
}

function module_is_available() {
    requireOs "Linux" || return 1
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/network}"
    source "$PREFERENCES_DIR/network/common.sh" 2>/dev/null || true

    echo "=========================================="
    echo "🌐 Setting up Preferences Network Watcher"
    echo "=========================================="

    # Stage default network hooks from this module
    installPreferencesNetworkHookDir "$modDir/network-hooks.d" "network"

    # Configure systemd user service on Linux
    if isPreferencesSystemdUserAvailable; then
        echo "⚙ Systemd User Session detected. Configuring network watcher service..."
        installPreferencesDir "$PREFERENCES_WORKSPACE_NETWORK/systemd"
        local targetServiceFile="$PREFERENCES_WORKSPACE_NETWORK/systemd/preferences-network-watcher.service"
        local templateFile="$modDir/systemd/preferences-network-watcher.service.template"

        if command -v envsubst &>/dev/null; then
            PREFERENCES_DIR=$PREFERENCES_DIR envsubst '$PREFERENCES_DIR' \
                < "$templateFile" > "$targetServiceFile"
        else
            sed "s|\\\$PREFERENCES_DIR|$PREFERENCES_DIR|g" \
                < "$templateFile" > "$targetServiceFile"
        fi

        if installPreferencesSystemdUserService 'preferences-network-watcher' "$targetServiceFile"; then
            echo "✓ Systemd user service 'preferences-network-watcher' successfully registered and started."
            echo "ℹ Service status: systemctl --user status preferences-network-watcher"
        else
            echo "⚠ Failed to enable systemd service for network watcher."
        fi
    fi

    echo "=========================================="
    echo "🎉 Network Watcher Installation Completed!"
    echo "📝 Execution Logs: $PREFERENCES_NETWORK_LOG"
    echo "=========================================="
}

#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source "$PREFERENCES_DIR/cron/common.sh"


function install_crontab {
    echo "⚙ Registering fallback task in user crontab..."
    installPreferencesCron 'preferences-cron-runner' "0 10 * * * /bin/bash $PREFERENCES_CRON_RUNNER"
    echo "✓ POSIX Crontab entry registered successfully."
    echo "ℹ View scheduled tasks with: crontab -l"
}

# Ensure log workspace directory exists
installPreferencesDir "$PREFERENCES_WORKSPACE_CRON"
installPreferencesSymlink "$PREFERENCES_CRON/cron.sh" "$PREFERENCES_WORKSPACE_CRON/cron.sh"

echo "=========================================="
echo "🔧 Setting up Preferences Task Scheduler"
echo "=========================================="

case "$PREFERENCES_OS" in
    'Darwin')
        echo "🍎 macOS Detected. Configuring LaunchAgent..."
        if installPreferencesLaunchAgent 'com.laphone.preferences.update' "$PREFERENCES_DIR/cron/com.laphone.preferences.update.plist"; then
            echo "✓ macOS LaunchAgent loaded successfully under standard user session."
        else
            echo "⚠ Failed to load LaunchAgent using launchctl. Falling back to POSIX crontab..."
            install_crontab
        fi
        ;;
        
    'Linux')
        echo "🐧 Linux Detected. Checking Systemd availability..."
        
        # Check if systemd user services are running and accessible
        if isPreferencesSystemdUserAvailable; then
            echo "⚙ Systemd User Session detected. Configuring systemd timer..."
            installPreferencesDir "$PREFERENCES_WORKSPACE_CRON/systemd"
            PREFERENCES_DIR=$PREFERENCES_DIR envsubst '$PREFERENCES_DIR' \
                < "$PREFERENCES_CRON/systemd/preferences-update.service.template" \
                > "$PREFERENCES_WORKSPACE_CRON/systemd/preferences-update.service"

            if installPreferencesSystemdUserService 'preferences-update' \
                "$PREFERENCES_WORKSPACE_CRON/systemd/preferences-update.service" \
                "$PREFERENCES_CRON/systemd/preferences-update.timer"; then
                echo "✓ Systemd user service and timer successfully registered and started."
                echo "ℹ Timer status: systemctl --user status preferences-update.timer"
            else
                echo "⚠ Failed to enable systemd timer. Falling back to POSIX crontab..."
                install_crontab
            fi
        else
            echo "ℹ Systemd user mode is unavailable or not running. Falling back to Crontab..."
            install_crontab
        fi
        ;;
        
    *)
        echo "💻 Alternative Platform Detected ($PREFERENCES_OS). Using Crontab fallback..."
        install_crontab
        ;;
esac

echo "=========================================="
echo "🎉 Scheduler Installation Completed!"
echo "📝 Execution Logs: $PREFERENCES_CRON_LOG"
echo "=========================================="

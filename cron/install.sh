#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"


function install_crontab {
    echo "⚙ Registering fallback task in user crontab..."
    installPreferencesCron 'preferences-cron-runner' "0 10 * * * /bin/bash $PREFERENCES_DIR/bin/preferences-cron-runner"
    echo "✓ POSIX Crontab entry registered successfully."
    echo "ℹ View scheduled tasks with: crontab -l"
}

# Ensure log workspace directory exists
installPreferencesDir "$PREFERENCES_DIR/.workspace/cron"
installPreferencesSymlink "$PREFERENCES_DIR/cron/cron.sh" "$PREFERENCES_DIR/.workspace/cron/cron.sh"

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
        if systemctl --user &>/dev/null; then
            echo "⚙ Systemd User Session detected. Configuring systemd timer..."
            if installPreferencesSystemdUserTimer 'preferences-update' "$PREFERENCES_DIR/cron/preferences-update.service" "$PREFERENCES_DIR/cron/preferences-update.timer"; then
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
echo "📝 Execution Logs: $PREFERENCES_DIR/.workspace/cron/cron.log"
echo "=========================================="

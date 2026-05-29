#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"

function install_crontab {
    echo "⚙ Registering fallback task in user crontab..."
    
    # Task run daily at 10:00 AM
    local cron_cmd="0 10 * * * /bin/bash $PREFERENCES_DIR/bin/preferences-cron-runner"
    
    # Get current crontab, excluding any existing preferences-cron-runner line
    local current_cron=""
    current_cron=$(crontab -l 2>/dev/null | grep -v "preferences-cron-runner" || true)
    
    # Update crontab
    (echo "$current_cron"; echo "$cron_cmd") | crontab -
    echo "✓ POSIX Crontab entry registered successfully."
    echo "ℹ View scheduled tasks with: crontab -l"
}

# Ensure log workspace directory exists
mkdir -p "$PREFERENCES_DIR/.workspace/cron"

echo "=========================================="
echo "🔧 Setting up Preferences Task Scheduler"
echo "=========================================="

case "$PREFERENCES_OS" in
    'Darwin')
        echo "🍎 macOS Detected. Configuring LaunchAgent..."
        
        target_dir="$HOME/Library/LaunchAgents"
        mkdir -p "$target_dir"
        target_plist="$target_dir/com.laphone.preferences.update.plist"
        
        # Stop and unload existing plist if loaded
        launchctl unload "$target_plist" &>/dev/null || true
        
        # Deploy plist with absolute paths replaced
        sed "s|%PREFERENCES_DIR%|$PREFERENCES_DIR|g" "$PREFERENCES_DIR/cron/com.laphone.preferences.update.plist" > "$target_plist"
        
        # Load the LaunchAgent
        if launchctl load "$target_plist"; then
            echo "✓ macOS LaunchAgent loaded successfully under standard user session."
            echo "ℹ Managed file: $target_plist"
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
            
            user_systemd_dir="$HOME/.config/systemd/user"
            mkdir -p "$user_systemd_dir"
            
            target_service="$user_systemd_dir/preferences-update.service"
            target_timer="$user_systemd_dir/preferences-update.timer"
            
            # Stop existing timer
            systemctl --user disable --now preferences-update.timer &>/dev/null || true
            
            # Deploy systemd files with actual paths replaced
            sed "s|%PREFERENCES_DIR%|$PREFERENCES_DIR|g" "$PREFERENCES_DIR/cron/preferences-update.service" > "$target_service"
            cp "$PREFERENCES_DIR/cron/preferences-update.timer" "$target_timer"
            
            # Reload, enable, and start timer
            systemctl --user daemon-reload
            if systemctl --user enable --now preferences-update.timer; then
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

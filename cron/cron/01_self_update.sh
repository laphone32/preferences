#!/usr/bin/env bash

source "$PREFERENCES_DIR/cron/common.sh"
LOG_FILE="${LOG_FILE:-$PREFERENCES_CRON_LOG}"

# 1. Self-updating preferences git repository
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Checking for Preferences repository updates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "$PREFERENCES_DIR/.git" ]; then
    cd "$PREFERENCES_DIR"
    # Ensure git fetch works under cron context
    if git fetch origin &>/dev/null; then
        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse @{u} 2>/dev/null)
        
        if [ -n "$REMOTE" ]; then
            BASE=$(git merge-base HEAD @{u} 2>/dev/null)
            
            if [ "$LOCAL" = "$REMOTE" ]; then
                echo "✓ Preferences repository is already up to date."
            elif [ "$LOCAL" = "$BASE" ]; then
                echo "📥 New changes detected! Pulling latest preferences..."
                if git pull --rebase; then
                    echo "✓ Successfully self-updated preferences repository."
                else
                    echo "⚠ Error: Failed to pull latest changes automatically."
                fi
            elif [ "$REMOTE" = "$BASE" ]; then
                echo "ℹ Notice: Local preferences has unpushed commits."
            else
                echo "⚠ Warning: Preferences repository branches have diverged."
            fi
        else
            echo "⚠ Warning: No upstream tracked branch found."
        fi
    else
        echo "⚠ Warning: Failed to fetch updates from remote origin (network offline?)."
    fi
else
    echo "ℹ Preferences is not a Git repository. Skipping self-update."
fi
echo ""

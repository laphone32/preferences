#!/usr/bin/env bash

# 1. Self-updating preferences git repository
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Checking for Preferences repository updates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "$PREFERENCES_DIR/.git" ]; then
    cd "$PREFERENCES_DIR"
    # Ensure git git-fetch works under cron context
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


# 3. Log file rotation (Keep it under 2000 lines to prevent bloat)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 Running Log Rotation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
MAX_LINES=2000
if [ -f "$LOG_FILE" ]; then
    LINE_COUNT=$(wc -l < "$LOG_FILE")
    if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
        echo "→ Log file currently has $LINE_COUNT lines. Pruning to last $MAX_LINES lines..."
        # Portable line pruning
        tail -n "$MAX_LINES" "$LOG_FILE" > "$LOG_FILE.tmp" 2>/dev/null
        mv "$LOG_FILE.tmp" "$LOG_FILE"
        echo "✓ Log file rotation complete."
    else
        echo "✓ Log file is within limits ($LINE_COUNT/$MAX_LINES lines). No rotation required."
    fi
fi
echo ""

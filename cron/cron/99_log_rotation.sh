#!/usr/bin/env bash

source "$PREFERENCES_DIR/cron/common.sh"
LOG_FILE="${LOG_FILE:-$PREFERENCES_CRON_LOG}"

# Log file rotation (Keep it under 3000 lines to prevent bloat)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 Running Log Rotation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
MAX_LINES=3000
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

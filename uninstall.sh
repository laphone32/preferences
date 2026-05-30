#!/usr/bin/env bash
# File: uninstall.sh

source "$(dirname "${BASH_SOURCE[0]}")/util/bootstrap.sh"
# Source the install.sh helper to load Action Constants and undo functions
source "$PREFERENCES_DIR/util/install.sh"

if [ ! -f "$PREFERENCES_INSTALL_MANIFEST" ]; then
    echo "No installation manifest found at $PREFERENCES_INSTALL_MANIFEST."
    echo "This project might not have been installed using the wrapper helpers."
    exit 1
fi

echo "=========================================="
echo "🧹 Starting Preferences Uninstallation"
echo "=========================================="

# Read lines in reverse order (LIFO) and dynamically invoke the corresponding namespaced undo function
tac "$PREFERENCES_INSTALL_MANIFEST" | while IFS='|' read -r action arg1 arg2 arg3 arg4; do
    undoFunc="undoPreferences${action}"
    if declare -f "$undoFunc" > /dev/null; then
        # Dynamically call the undo function with the logged parameters
        "$undoFunc" "$arg1" "$arg2" "$arg3" "$arg4"
    else
        echo "⚠ Warning: No undo handler found for action '$action' ($undoFunc)"
    fi
done

# Clean up workspace
echo "Cleaning up local workspace..."
rm -rf "$PREFERENCES_WORKSPACE"

echo "✓ Uninstallation completed successfully!"

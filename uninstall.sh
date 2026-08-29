#!/usr/bin/env bash
# File: uninstall.sh

source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"
# Source the install.sh helper to load Action Constants and undo functions
sourceShare install install.sh 2>/dev/null || source "$PREFERENCES_DIR/install/share/bash/install.sh"

if ! uninstallPreferencesManifest; then
    exit 1
fi

# Clean up workspace
echo "Cleaning up local workspace..."
rm -rf "$PREFERENCES_WORKSPACE"

echo "✓ Uninstallation completed successfully!"

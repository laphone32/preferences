#!/usr/bin/env bash
# File: uninstall.sh

source "$(dirname "${BASH_SOURCE[0]}")/util/bootstrap.sh"
# Source the install.sh helper to load Action Constants and undo functions
source "$PREFERENCES_DIR/util/install.sh"

if ! uninstallPreferencesManifest; then
    exit 1
fi

# Clean up workspace
echo "Cleaning up local workspace..."
rm -rf "$PREFERENCES_WORKSPACE"

echo "✓ Uninstallation completed successfully!"

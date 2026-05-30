#!/usr/bin/env bash

# Calculate PREFERENCES_DIR dynamically if not set
if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi

# Source bootstrap to load environment/utilities
if [ -f "$PREFERENCES_DIR/util/bootstrap.sh" ]; then
    source "$PREFERENCES_DIR/util/bootstrap.sh"
fi

echo "=========================================="
echo "📥 Fetching and installing Antigravity CLI..."
echo "=========================================="

if [ "$PREFERENCES_OS" == "Darwin" ] || [ "$PREFERENCES_OS" == "Linux" ]; then
    echo "Installing agy via official installer..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash

    # Ensure ~/.local/bin is in PATH for immediate use
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if command -v agy &> /dev/null; then
        echo "✓ Antigravity CLI (agy) installation complete."
    else
        echo "⚠ agy binary not found in PATH after install. You may need to restart your shell or add ~/.local/bin to PATH."
    fi
else
    echo "Unsupported OS for automatic agy installation: $PREFERENCES_OS"
    exit 1
fi

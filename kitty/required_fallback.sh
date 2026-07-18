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
echo "📥 Fetching and installing Kitty terminal..."
echo "=========================================="

if ! command -v kitty &> /dev/null; then
    echo "Installing kitty via official installer binary..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # Create symbolic links for PATH integration
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/"

    # Install desktop entry
    mkdir -p "$HOME/.local/share/applications"
    if [ -f "$HOME/.local/kitty.app/share/applications/kitty.desktop" ]; then
        cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
        # Update the icon path in the desktop file
        sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty.desktop"
    fi

    # Register auto-update cron task for fallback installation
    installPreferencesDir "$PREFERENCES_DIR/.workspace/kitty"
    installPreferencesSymlink "$PREFERENCES_DIR/kitty/cron.sh" "$PREFERENCES_DIR/.workspace/kitty/cron.sh"
    
    echo "✓ Kitty terminal fallback installation complete."
fi

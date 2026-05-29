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

if [ "$PREFERENCES_OS" == "Darwin" ]; then
    if command -v brew &> /dev/null; then
        if brew list --cask kitty &>/dev/null; then
            echo "Upgrading kitty via Homebrew..."
            brew upgrade --cask kitty
        else
            echo "Installing kitty via Homebrew..."
            brew install --cask kitty
        fi
    else
        echo "Error: Homebrew is not installed. Please install Homebrew first or install kitty manually."
        exit 1
    fi
elif [ "$PREFERENCES_OS" == "Linux" ]; then
    echo "Installing kitty via official installer binary..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    # Create symbolic links for PATH integration
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/"

    # Install desktop entry
    mkdir -p "$HOME/.local/share/applications"
    cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
    # Update the icon path in the desktop file
    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty.desktop"
    
    echo "✓ Kitty terminal installation/update complete on Linux."
else
    echo "Unsupported OS for automatic kitty installation: $PREFERENCES_OS"
    exit 1
fi

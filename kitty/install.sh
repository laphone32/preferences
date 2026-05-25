#!/usr/bin/env bash

if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi

source $PREFERENCES_DIR/kitty/common.sh

# Ensure ~/.local/bin is in PATH for the current shell execution
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Detect OS if not already set
if [ -z "$PREFERENCES_OS" ]; then
    if [ -f "$PREFERENCES_DIR/util/environment.sh" ]; then
        source "$PREFERENCES_DIR/util/environment.sh"
    else
        case $OSTYPE in
            'darwin'*) PREFERENCES_OS='Darwin' ;;
            'linux'*) PREFERENCES_OS='Linux' ;;
            *) PREFERENCES_OS='Windows' ;;
        esac
    fi
fi

# Install kitty terminal if not already present
if ! command -v kitty &> /dev/null; then
    echo "Installing kitty terminal..."
    if [ "$PREFERENCES_OS" == "Darwin" ]; then
        if command -v brew &> /dev/null; then
            echo "Installing kitty via Homebrew..."
            brew install --cask kitty
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
    else
        echo "Unsupported OS for automatic kitty installation: $PREFERENCES_OS"
    fi
else
    echo "✓ kitty terminal is already installed"
fi

mkdir -p $PREFERENCES_KITTY_LOCAL
mkdir -p $PREFERENCES_WORKSPACE_KITTY

PREFERENCES_KITTY_CONFIG="$PREFERENCES_KITTY/config"

# shell
DEFAULT_SHELL=$(which bash) envsubst '$DEFAULT_SHELL' < $PREFERENCES_KITTY_CONFIG/device.conf.template > $PREFERENCES_WORKSPACE_KITTY/device.conf
ln -sf $PREFERENCES_WORKSPACE_KITTY/device.conf $PREFERENCES_KITTY_LOCAL/device.conf


# color scheme
mkdir -p $PREFERENCES_WORKSPACE_KITTY/color-theme
function dump_theme {
    kitty +kitten themes --dump-theme $1 > $PREFERENCES_WORKSPACE_KITTY/color-theme/$2.conf
}
dump_theme 'Chalk' 'default'
dump_theme 'Nord' 'vim'
dump_theme 'Vaughn' 'remote'
dump_theme 'Earthsong' 'container'
dump_theme 'Solarized Darcula' 'uat'
dump_theme 'Red Alert' 'prod'

ln -sf $PREFERENCES_WORKSPACE_KITTY/color-theme/default.conf $PREFERENCES_KITTY_LOCAL/theme.conf


# os specific
case $PREFERENCES_OS in
    'Darwin')
        ln -sf $PREFERENCES_DIR/kitty/os/kitty_macos.conf $PREFERENCES_KITTY_LOCAL/os.conf
        ;;
    'Linux')
        ln -sf $PREFERENCES_DIR/kitty/os/kitty_linux.conf $PREFERENCES_KITTY_LOCAL/os.conf
        ;;
    *)
        ;;
esac


# fonts
ln -sf $PREFERENCES_KITTY/fonts/default.conf $PREFERENCES_KITTY_LOCAL/fonts.conf


# watcher
PREFERENCES_DIR=$PREFERENCES_DIR PREFERENCES_KITTY_LOCAL=$PREFERENCES_KITTY_LOCAL envsubst '$PREFERENCES_DIR,$PREFERENCES_KITTY_LOCAL' < $PREFERENCES_KITTY_CONFIG/watcher.py.template > $PREFERENCES_WORKSPACE_KITTY/watcher.py
ln -sf $PREFERENCES_WORKSPACE_KITTY/watcher.py $PREFERENCES_KITTY_LOCAL/watcher.py


# configs
ln -sf $PREFERENCES_KITTY_CONFIG/kitty.conf $PREFERENCES_KITTY_LOCAL/kitty.conf

# quick access terminal
ln -sf $PREFERENCES_KITTY_CONFIG/quick-access-terminal.conf $PREFERENCES_KITTY_LOCAL/quick-access-terminal.conf


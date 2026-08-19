#!/usr/bin/env bash
# File: kitty/module_attribute.sh

function module_get_name() {
    echo "kitty"
}

function module_get_gui_packages() {
    echo "kitty"
}

function module_required_fallback() {
    if ! command -v kitty &> /dev/null; then
        echo "Installing kitty via official installer binary..."
        curl -sSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

        # Create symbolic links for PATH integration
        installPreferencesDir "$HOME/.local/bin"
        installPreferencesSymlink "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
        installPreferencesSymlink "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"

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
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/kitty}"
    source "$PREFERENCES_DIR/kitty/common.sh"

    # Ensure ~/.local/bin is in PATH for the current shell execution
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    installPreferencesDir "$PREFERENCES_KITTY_LOCAL"
    installPreferencesDir "$PREFERENCES_WORKSPACE_KITTY"

    local PREFERENCES_KITTY_CONFIG="$PREFERENCES_KITTY/config"

    # shell
    DEFAULT_SHELL=$(which bash) envsubst '$DEFAULT_SHELL' < "$PREFERENCES_KITTY_CONFIG/device.conf.template" > "$PREFERENCES_WORKSPACE_KITTY/device.conf"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/device.conf" "$PREFERENCES_KITTY_LOCAL/device.conf"

    # color scheme
    installPreferencesDir "$PREFERENCES_WORKSPACE_KITTY/color-theme"
    function dump_theme {
        if command -v kitty &>/dev/null; then
            kitty +kitten themes --dump-theme "$1" > "$PREFERENCES_WORKSPACE_KITTY/color-theme/$2.conf" 2>/dev/null || true
        fi
    }
    dump_theme 'Chalk' 'default'
    dump_theme 'Nord' 'vim'
    dump_theme 'Vaughn' 'remote'
    dump_theme 'Earthsong' 'container'
    dump_theme 'Solarized Darcula' 'uat'
    dump_theme 'Red Alert' 'prod'

    installPreferencesSymlink "$PREFERENCES_KITTY/color-theme/pinkie.conf" "$PREFERENCES_WORKSPACE_KITTY/color-theme/sudo.conf"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/color-theme/default.conf" "$PREFERENCES_KITTY_LOCAL/theme.conf"

    # os specific
    case "$PREFERENCES_OS" in
        'Darwin')
            installPreferencesSymlink "$PREFERENCES_DIR/kitty/os/kitty_macos.conf" "$PREFERENCES_KITTY_LOCAL/os.conf"
            ;;
        'Linux')
            installPreferencesSymlink "$PREFERENCES_DIR/kitty/os/kitty_linux.conf" "$PREFERENCES_KITTY_LOCAL/os.conf"
            ;;
        *)
            ;;
    esac

    # fonts
    installPreferencesSymlink "$PREFERENCES_KITTY/fonts/default.conf" "$PREFERENCES_KITTY_LOCAL/fonts.conf"

    # watcher
    PREFERENCES_DIR=$PREFERENCES_DIR PREFERENCES_KITTY_LOCAL=$PREFERENCES_KITTY_LOCAL envsubst '$PREFERENCES_DIR,$PREFERENCES_KITTY_LOCAL' < "$PREFERENCES_KITTY_CONFIG/watcher.py.template" > "$PREFERENCES_WORKSPACE_KITTY/watcher.py"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/watcher.py" "$PREFERENCES_KITTY_LOCAL/watcher.py"

    # configs
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/kitty.conf" "$PREFERENCES_KITTY_LOCAL/kitty.conf"

    # quick access terminal
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/quick-access-terminal.conf" "$PREFERENCES_KITTY_LOCAL/quick-access-terminal.conf"
}

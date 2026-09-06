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
        installPreferencesCronDir "$PREFERENCES_DIR/kitty/cron" "kitty"

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

    local PREFERENCES_KITTY_CONFIG="$PREFERENCES_KITTY/config"

    # dispatcher compilation
    source "$PREFERENCES_DIR/bash/common.sh"
    [ -z "${PREFERENCES_PATH:-}" ] && aggregatePreferencesEnv

    installPreferencesDir "$PREFERENCES_WORKSPACE_KITTY/bin"
    PREFERENCES_PATH="$PREFERENCES_PATH" \
    PREFERENCES_DIR="$PREFERENCES_DIR" \
    envsubst '$PREFERENCES_PATH $PREFERENCES_DIR' < "$PREFERENCES_KITTY_CONFIG/kitty-open.template" > "$PREFERENCES_WORKSPACE_KITTY/bin/kitty-open"
    chmod +x "$PREFERENCES_WORKSPACE_KITTY/bin/kitty-open"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/bin/kitty-open" "$HOME/.local/bin/kitty-open"

    # shell & opener
    DEFAULT_SHELL=$(which bash) \
    PREFERENCES_KITTY_OPEN="$PREFERENCES_WORKSPACE_KITTY/bin/kitty-open" \
    envsubst '$DEFAULT_SHELL $PREFERENCES_KITTY_OPEN' < "$PREFERENCES_KITTY_CONFIG/device.conf.template" > "$PREFERENCES_WORKSPACE_KITTY/device.conf"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/device.conf" "$PREFERENCES_KITTY_LOCAL/device.conf"

    # themes
    python3 "$modDir/compile/compile_themes.py"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/theme/default.conf" "$PREFERENCES_KITTY_LOCAL/theme.conf"


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

    # watcher & path helpers
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/kitty_path.py" "$PREFERENCES_KITTY_LOCAL/kitty_path.py"
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/watcher.py" "$PREFERENCES_KITTY_LOCAL/watcher.py"

    # configs
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/kitty.conf" "$PREFERENCES_KITTY_LOCAL/kitty.conf"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KITTY/device_font.conf" "$PREFERENCES_KITTY_LOCAL/device_font.conf"

    # font size management
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/font_size.py" "$PREFERENCES_KITTY_LOCAL/font_size.py"
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/adjust_font_size.py" "$PREFERENCES_KITTY_LOCAL/adjust_font_size.py"

    # quick access terminal
    installPreferencesSymlink "$PREFERENCES_KITTY_CONFIG/quick-access-terminal.conf" "$PREFERENCES_KITTY_LOCAL/quick-access-terminal.conf"
}

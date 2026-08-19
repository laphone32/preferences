#!/usr/bin/env bash
# File: keyd/module_attribute.sh

function module_get_name() {
    echo "keyd"
}

function module_is_available() {
    requireOs "Linux"
}

function module_get_gui_packages() {
    echo "keyd keyd-application-mapper"
}

function module_required_fallback() {
    source "$PREFERENCES_DIR/util/override.sh"

    if ! command -v keyd &> /dev/null && command -v keyd.rvaiya &> /dev/null; then
        wrap '' 'keyd.rvaiya' 'keyd'
    fi
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/keyd}"
    source "$PREFERENCES_DIR/keyd/common.sh"

    echo "Installing Centralized Keyd module..."

    # Compile keybinds.json to .workspace/keyd/
    python3 "$PREFERENCES_KEYD/bin/compile-keybinds.py" "$PREFERENCES_KEYD/keybinds.json"

    # Deploy keyd User Configuration
    installPreferencesDir "$PREFERENCES_KEYBINDS_LOCAL"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KEYD/default.conf" "$PREFERENCES_KEYBINDS_LOCAL/default.conf"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_KEYD/app.conf" "$PREFERENCES_KEYBINDS_LOCAL/app.conf"

    # Link System $KEYD_ETC_DIR/default.conf -> ~/.config/keyd/default.conf
    if [ -d "$KEYD_ETC_DIR" ]; then
        echo "Linking $KEYD_ETC_DIR/default.conf -> $PREFERENCES_KEYBINDS_LOCAL/default.conf..."
        installPreferencesSudoSymlink "$PREFERENCES_KEYBINDS_LOCAL/default.conf" "$KEYD_ETC_DIR/default.conf"

        if [ -n "$KEYD_BIN" ]; then
            enablePreferencesSystemdSystemService "$KEYD_BIN"
            sudo "$KEYD_BIN" reload 2>/dev/null || true
        else
            echo "Warning: keyd binary not found, unable to reload."
        fi
    fi

    # Configure libinput quirks so trackpad disable-while-typing recognizes keyd virtual keyboard
    local LIBINPUT_QUIRKS_CONTENT="[Virtual Keyboard]
MatchUdevType=keyboard
MatchName=keyd virtual keyboard
AttrKeyboardIntegration=internal"

    echo "Configuring libinput quirks in $LIBINPUT_QUIRKS_FILE..."
    installPreferencesSudoSection "$LIBINPUT_QUIRKS_FILE" "keyd" "$LIBINPUT_QUIRKS_CONTENT"

    # Install keyd-application-mapper GNOME extension and User Service
    if [ -n "$KEYD_BIN" ] && command -v keyd-application-mapper &> /dev/null; then
        echo "Setting up keyd-application-mapper..."

        local KEYD_VERSION=$("$KEYD_BIN" -v 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')

        source "$PREFERENCES_DIR/util/environment.sh" 2>/dev/null || true
        if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ]; then
            # Download GNOME Extension matching keyd version
            local GNOME_EXT_WORKSPACE="$PREFERENCES_WORKSPACE_KEYD/gnome-extension"
            if [ ! -d "$GNOME_EXT_WORKSPACE" ]; then
                echo "Downloading GNOME extension for keyd $KEYD_VERSION..."
                mkdir -p "$GNOME_EXT_WORKSPACE"
                curl -sL "https://github.com/rvaiya/keyd/archive/refs/tags/${KEYD_VERSION}.tar.gz" | tar -xz -C "$GNOME_EXT_WORKSPACE" --strip-components=3 "keyd-${KEYD_VERSION#v}/data/gnome-extension-45"
            fi

            # Install and enable GNOME Extension
            installPreferencesGnomeExtension "$GNOME_EXT_WORKSPACE" "keyd"
        else
            echo "Non-GNOME DE detected ($PREFERENCES_DESKTOP_ENVIRONMENT). Skipping GNOME extension installation."
        fi

        # Setup keyd-application-mapper systemd user service for non-GNOME environments
        installPreferencesSystemdUserService "keyd-application-mapper" "$PREFERENCES_DIR/keyd/systemd/keyd-application-mapper.service"

        # Add user to keyd group so they can interact with the mapper without sudo
        echo "Adding $USER to the keyd group..."
        sudo usermod -aG keyd "$USER" 2>/dev/null || true
        echo "Note: You may need to log out and log back in for group changes to take effect."
    fi

    # Apply GNOME settings (unbinding GNOME Shell conflicts)
    if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ] && command -v gsettings &>/dev/null; then
        echo "Applying GNOME gsettings keybindings overrides..."
        gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true
    fi

    echo "Keyd module installation complete!"
}

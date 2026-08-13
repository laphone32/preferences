#!/usr/bin/env bash
# File: keyd/install.sh

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source "$PREFERENCES_DIR/keyd/common.sh"


# keyd is Linux-only
if [ "$PREFERENCES_OS" != "Linux" ]; then
    return 0
fi

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
        sudo systemctl enable --now "$KEYD_BIN" 2>/dev/null || true
        sudo "$KEYD_BIN" reload 2>/dev/null || true
    else
        echo "Warning: keyd binary not found, unable to reload."
    fi
fi

# Install keyd-application-mapper GNOME extension and User Service
if [ -n "$KEYD_BIN" ] && command -v keyd-application-mapper &> /dev/null; then
    echo "Setting up keyd-application-mapper..."

    KEYD_VERSION=$("$KEYD_BIN" -v | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')

    source "$PREFERENCES_DIR/util/environment.sh" 2>/dev/null || true
    if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ]; then
        # Download GNOME Extension matching keyd version
        GNOME_EXT_WORKSPACE="$PREFERENCES_WORKSPACE_KEYD/gnome-extension"
        if [ ! -d "$GNOME_EXT_WORKSPACE" ]; then
            echo "Downloading GNOME extension for keyd $KEYD_VERSION..."
            mkdir -p "$GNOME_EXT_WORKSPACE"
            curl -sL "https://github.com/rvaiya/keyd/archive/refs/tags/${KEYD_VERSION}.tar.gz" | tar -xz -C "$GNOME_EXT_WORKSPACE" --strip-components=3 "keyd-${KEYD_VERSION#v}/data/gnome-extension-45"
        fi

        # Symlink Extension
        installPreferencesDir "$GNOME_EXTENSIONS_DIR"
        installPreferencesSymlink "$GNOME_EXT_WORKSPACE" "$GNOME_EXTENSIONS_DIR/keyd"

        if command -v gnome-extensions &> /dev/null; then
            gnome-extensions enable keyd 2>/dev/null || true
        fi
    else
        echo "Non-GNOME DE detected ($PREFERENCES_DESKTOP_ENVIRONMENT). Skipping GNOME extension installation."
    fi

    # Setup keyd-application-mapper systemd user service for non-GNOME environments
    mkdir -p "$HOME/.config/systemd/user"
    installPreferencesSymlink "$PREFERENCES_DIR/keyd/systemd/keyd-application-mapper.service" "$HOME/.config/systemd/user/keyd-application-mapper.service"

    # Reload systemd user daemon so it picks up the new service file
    systemctl --user daemon-reload

    # Add user to keyd group so they can interact with the mapper without sudo
    echo "Adding $USER to the keyd group..."
    sudo usermod -aG keyd "$USER"
    echo "Note: You may need to log out and log back in for group changes to take effect."
fi

# Apply GNOME settings (unbinding GNOME Shell conflicts)
if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ] && command -v gsettings &>/dev/null; then
    echo "Applying GNOME gsettings keybindings overrides..."

    # Disable version validation so the extension works on future GNOME Shell versions (like 50+)
    gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true

fi

echo "Keyd module installation complete!"

#!/usr/bin/env bash
# File: shortcut/module_attribute.sh

function module_get_name() {
    echo "shortcut"
}

function module_is_available() {
    requireOs "Linux"
}

function module_get_gui_packages() {
    echo "keyd keyd-application-mapper"
}

function module_required_fallback() {
    source "$PREFERENCES_DIR/shortcut/common.sh"

    if [ -n "$KEYD_BIN" ] && ! command -v keyd &>/dev/null; then
        installPreferencesDir "$HOME/.local/bin"
        installPreferencesSymlink "$(command -v "$KEYD_BIN")" "$HOME/.local/bin/keyd"
    fi
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/shortcut}"
    source "$PREFERENCES_DIR/shortcut/common.sh"

    if [ -n "$KEYD_BIN" ] && ! command -v keyd &>/dev/null; then
        installPreferencesDir "$HOME/.local/bin"
        installPreferencesSymlink "$(command -v "$KEYD_BIN")" "$HOME/.local/bin/keyd"
    fi

    echo "Installing Centralized Shortcut module..."

    # Compile keybinds.json to .workspace/shortcut/
    python3 "$PREFERENCES_SHORTCUT/bin/compile-keybinds.py" "$PREFERENCES_SHORTCUT/keybinds.json"

    sourceShare bash environment.sh 2>/dev/null || source "$PREFERENCES_DIR/bash/share/bash/environment.sh" 2>/dev/null || true

    # Deploy Hyprland Configuration if Hyprland is detected or directory exists
    if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "hyprland" ] || [ -d "$HOME/.config/hypr" ]; then
        echo "Setting up Hyprland shortcuts..."
        installPreferencesDir "$HOME/.config/hypr"
        if [ -f "$PREFERENCES_WORKSPACE_SHORTCUT/preferences_keybind.lua" ]; then
            installPreferencesSymlink "$PREFERENCES_WORKSPACE_SHORTCUT/preferences_keybind.lua" "$HOME/.config/hypr/preferences_keybind.lua"
        fi

        # Remove legacy keybinds.lua symlink if present
        if [ -L "$HOME/.config/hypr/keybinds.lua" ]; then
            rm -f "$HOME/.config/hypr/keybinds.lua"
        fi

        # Determine target Hyprland Lua config file (hypr.lua preferred, fallback to hyprland.lua)
        local hyprConfigFile="$HOME/.config/hypr/hypr.lua"
        if [ ! -f "$hyprConfigFile" ] && [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
            hyprConfigFile="$HOME/.config/hypr/hyprland.lua"
        fi

        local hyprRequireContent='package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path
local ok, preferences_keybind = pcall(require, "preferences_keybind")
if ok and type(preferences_keybind.setup) == "function" then
    preferences_keybind.setup()
end'
        installPreferencesSection "$hyprConfigFile" "preferences_keybind" "$hyprRequireContent"
    fi

    # Deploy keyd User Configuration (used in GNOME / X11)
    installPreferencesDir "$PREFERENCES_KEYBINDS_LOCAL"
    if [ -f "$PREFERENCES_WORKSPACE_SHORTCUT/default.conf" ]; then
        installPreferencesSymlink "$PREFERENCES_WORKSPACE_SHORTCUT/default.conf" "$PREFERENCES_KEYBINDS_LOCAL/default.conf"
    fi
    if [ -f "$PREFERENCES_WORKSPACE_SHORTCUT/app.conf" ]; then
        installPreferencesSymlink "$PREFERENCES_WORKSPACE_SHORTCUT/app.conf" "$PREFERENCES_KEYBINDS_LOCAL/app.conf"
    fi

    # Link System $KEYD_ETC_DIR/default.conf -> ~/.config/keyd/default.conf
    if [ -d "$KEYD_ETC_DIR" ] && [ -f "$PREFERENCES_KEYBINDS_LOCAL/default.conf" ]; then
        echo "Linking $KEYD_ETC_DIR/default.conf -> $PREFERENCES_KEYBINDS_LOCAL/default.conf..."
        installPreferencesSudoSymlink "$PREFERENCES_KEYBINDS_LOCAL/default.conf" "$KEYD_ETC_DIR/default.conf"

        if [ -n "$KEYD_BIN" ]; then
            enablePreferencesSystemdSystemService "$KEYD_BIN"
            "$KEYD_BIN" reload 2>/dev/null || sudo "$KEYD_BIN" reload 2>/dev/null || true
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

        sourceShare bash environment.sh 2>/dev/null || source "$PREFERENCES_DIR/bash/share/bash/environment.sh" 2>/dev/null || true
        if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ]; then
            # Download GNOME Extension matching keyd version
            local GNOME_EXT_WORKSPACE="$PREFERENCES_WORKSPACE_SHORTCUT/gnome-extension"
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

        # Setup keyd-application-mapper systemd user service for non-GNOME and non-Hyprland environments
        if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" != "hyprland" ] && [ "$PREFERENCES_DESKTOP_ENVIRONMENT" != "gnome" ]; then
            installPreferencesSystemdUserService "keyd-application-mapper" "$PREFERENCES_DIR/shortcut/systemd/keyd-application-mapper.service"
        fi

        # Add user to keyd group only if not already present
        if ! id -nG "$USER" 2>/dev/null | grep -qw "keyd"; then
            echo "Adding $USER to the keyd group..."
            sudo usermod -aG keyd "$USER" 2>/dev/null || true
            echo "Note: You may need to log out and log back in for group changes to take effect."
        fi
    fi

    # Install Polkit rule allowing keyd group to manage keyd.service without password
    local POLKIT_RULES_DIR="/etc/polkit-1/rules.d"
    local POLKIT_SRC="$PREFERENCES_DIR/shortcut/polkit/90-keyd-session.rules"
    if [ -f "$POLKIT_SRC" ] && { [ -d "/etc/polkit-1" ] || command -v pkexec &>/dev/null; }; then
        echo "Installing Polkit rule for keyd to $POLKIT_RULES_DIR/90-keyd-session.rules..."
        sudo mkdir -p "$POLKIT_RULES_DIR"
        sudo cp "$POLKIT_SRC" "$POLKIT_RULES_DIR/90-keyd-session.rules"
        sudo chmod 644 "$POLKIT_RULES_DIR/90-keyd-session.rules"
        sudo chown root:root "$POLKIT_RULES_DIR/90-keyd-session.rules" 2>/dev/null || true
    fi

    # Deploy GNOME session activator autostart entry
    local AUTOSTART_DIR="$HOME/.config/autostart"
    local GNOME_AUTOSTART_SRC="$PREFERENCES_DIR/shortcut/autostart/keyd-gnome.desktop"
    if [ -f "$GNOME_AUTOSTART_SRC" ]; then
        installPreferencesDir "$AUTOSTART_DIR"
        installPreferencesSymlink "$GNOME_AUTOSTART_SRC" "$AUTOSTART_DIR/keyd-gnome.desktop"
    fi

    # Apply GNOME settings (unbinding GNOME Shell conflicts and applying shortcuts)
    if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ] && command -v gsettings &>/dev/null; then
        echo "Applying GNOME gsettings keybindings overrides..."
        gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true

        if [ -x "$PREFERENCES_WORKSPACE_SHORTCUT/gnome-shortcuts.sh" ]; then
            "$PREFERENCES_WORKSPACE_SHORTCUT/gnome-shortcuts.sh" 2>/dev/null || true
        fi
    fi

    echo "Shortcut module installation complete!"
}

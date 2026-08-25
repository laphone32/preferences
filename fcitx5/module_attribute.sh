#!/usr/bin/env bash
# File: fcitx5/module_attribute.sh

function module_is_available() {
    requireOs "Linux" && isGuiEnvironment
}

function module_get_gui_packages() {
    echo "fcitx5"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/fcitx5}"
    source "$PREFERENCES_DIR/fcitx5/common.sh" 2>/dev/null || true

    echo "Configuring fcitx5 module..."

    # 1. Environment variables in /etc/environment
    local FCITX5_ENV="GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx"

    echo "Configuring environment variables in /etc/environment..."
    installPreferencesSudoSection "/etc/environment" "fcitx5" "$FCITX5_ENV"

    # 2. GNOME Shell Extension (kimpanel)
    if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ]; then
        local GNOME_EXT_WORKSPACE="$PREFERENCES_WORKSPACE_FCITX5_KIMPANEL"
        if [ ! -d "$GNOME_EXT_WORKSPACE" ] || [ ! -f "$GNOME_EXT_WORKSPACE/metadata.json" ]; then
            echo "Downloading kimpanel GNOME Shell extension..."
            mkdir -p "$GNOME_EXT_WORKSPACE"

            # Query extension download zip URL dynamically from extensions.gnome.org API
            local shell_ver
            shell_ver=$(gnome-shell --version 2>/dev/null | awk '{print $3}' | cut -d. -f1)
            local zip_url
            zip_url=$(curl -s "https://extensions.gnome.org/extension-info/?pk=261" | python3 -c '
import sys, json
data = json.load(sys.stdin)
ver_map = data.get("shell_version_map", {})
target_ver = sys.argv[1] if len(sys.argv) > 1 else ""
entry = ver_map.get(target_ver)
if not entry and ver_map:
    entry = max(ver_map.values(), key=lambda x: x.get("version", 0))
if entry:
    ver = entry.get("version", 0)
    print(f"https://extensions.gnome.org/extension-data/kimpanelkde.org.v{ver}.shell-extension.zip")
' "$shell_ver")

            if [ -n "$zip_url" ]; then
                local tmp_zip="/tmp/kimpanel-ext-$$.zip"
                if curl -sSL "$zip_url" -o "$tmp_zip" 2>/dev/null && [ -f "$tmp_zip" ]; then
                    unzip -q -o "$tmp_zip" -d "$GNOME_EXT_WORKSPACE" 2>/dev/null || true
                    rm -f "$tmp_zip"
                fi
            fi
        fi

        if [ -f "$GNOME_EXT_WORKSPACE/metadata.json" ]; then
            echo "Installing and enabling kimpanel GNOME Shell extension..."
            installPreferencesGnomeExtension "$GNOME_EXT_WORKSPACE" "kimpanel@kde.org"
        else
            echo "ℹ Notice: kimpanel extension files not found or could not be downloaded."
        fi
    fi

    # 3. Autostart Desktop Entry
    local FCITX5_DESKTOP_SOURCE="/usr/share/applications/org.fcitx.Fcitx5.desktop"
    local FCITX5_AUTOSTART_TARGET="$HOME/.config/autostart/org.fcitx.Fcitx5.desktop"
    if [ -f "$FCITX5_DESKTOP_SOURCE" ]; then
        echo "Configuring fcitx5 autostart..."
        installPreferencesDir "$HOME/.config/autostart"
        installPreferencesSymlink "$FCITX5_DESKTOP_SOURCE" "$FCITX5_AUTOSTART_TARGET"
    fi

    # 4. GNOME xsettings overrides
    if [ "$PREFERENCES_DESKTOP_ENVIRONMENT" == "gnome" ] && command -v gsettings &>/dev/null; then
        echo "Setting GNOME xsettings overrides for Gtk/IMModule..."
        gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule':<'fcitx'>}" 2>/dev/null || true
    fi

    # 5. im-config setup
    if command -v im-config &>/dev/null; then
        echo "Setting default input method framework via im-config..."
        im-config -n fcitx5 2>/dev/null || true
    fi

    echo "✓ fcitx5 module installation complete!"
}

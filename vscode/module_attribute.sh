#!/usr/bin/env bash
# File: vscode/module_attribute.sh

function module_get_name() {
    echo "vscode"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/vscode}"
    local PREFERENCES_WORKSPACE_VSCODE="$(workspace vscode)"

    case "$PREFERENCES_OS" in
        'Darwin')
            installPreferencesSymlink "$modDir/os/macos.env" "$PREFERENCES_WORKSPACE_VSCODE/os.env"
            ;;
        'Linux')
            installPreferencesSymlink "$modDir/os/linux.env" "$PREFERENCES_WORKSPACE_VSCODE/os.env"
            ;;
        *)
            ;;
    esac

    source "$modDir/common.sh"
    installPreferencesDir "$PREFERENCES_VSCODE_LOCAL"

    DEFAULT_SHELL=$(which bash) envsubst '$DEFAULT_SHELL $PREFERENCES_VSCODE_EDITOR_FONT_SIZE $PREFERENCES_VSCODE_DEBUG_FONT_SIZE $PREFERENCES_VSCODE_MARKDOWN_FONT_SIZE $PREFERENCES_VSCODE_SCM_FONT_SIZE $PREFERENCES_VSCODE_TERMINAL_FONT_SIZE $PREFERENCES_VSCODE_APC_FONT_SIZE' < "$PREFERENCES_VSCODE_CONFIG/settings.json.template" > "$PREFERENCES_WORKSPACE_VSCODE/settings.json"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_VSCODE/settings.json" "$PREFERENCES_VSCODE_LOCAL/settings.json"

    # keybindings.json
    installPreferencesSymlink "$PREFERENCES_VSCODE_CONFIG/keybindings.json" "$PREFERENCES_VSCODE_LOCAL/keybindings.json"
}

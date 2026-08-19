#!/usr/bin/env bash
# File: vscode/module_attribute.sh

function module_get_name() {
    echo "vscode"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/vscode}"
    source "$PREFERENCES_DIR/vscode/common.sh"

    installPreferencesDir "$PREFERENCES_VSCODE_LOCAL"
    installPreferencesDir "$PREFERENCES_WORKSPACE_VSCODE"

    # settings.json
    if [[ "$PREFERENCES_OS" == "Linux" ]]; then
        export PREFERENCES_VSCODE_EDITOR_FONT_SIZE=20
        export PREFERENCES_VSCODE_DEBUG_FONT_SIZE=18
        export PREFERENCES_VSCODE_MARKDOWN_FONT_SIZE=18
        export PREFERENCES_VSCODE_SCM_FONT_SIZE=16
        export PREFERENCES_VSCODE_TERMINAL_FONT_SIZE=20
        export PREFERENCES_VSCODE_APC_FONT_SIZE=20
    else
        export PREFERENCES_VSCODE_EDITOR_FONT_SIZE=18
        export PREFERENCES_VSCODE_DEBUG_FONT_SIZE=16
        export PREFERENCES_VSCODE_MARKDOWN_FONT_SIZE=16
        export PREFERENCES_VSCODE_SCM_FONT_SIZE=14
        export PREFERENCES_VSCODE_TERMINAL_FONT_SIZE=18
        export PREFERENCES_VSCODE_APC_FONT_SIZE=18
    fi

    DEFAULT_SHELL=$(which bash) envsubst '$DEFAULT_SHELL $PREFERENCES_VSCODE_EDITOR_FONT_SIZE $PREFERENCES_VSCODE_DEBUG_FONT_SIZE $PREFERENCES_VSCODE_MARKDOWN_FONT_SIZE $PREFERENCES_VSCODE_SCM_FONT_SIZE $PREFERENCES_VSCODE_TERMINAL_FONT_SIZE $PREFERENCES_VSCODE_APC_FONT_SIZE' < "$PREFERENCES_VSCODE_CONFIG/settings.json.template" > "$PREFERENCES_WORKSPACE_VSCODE/settings.json"
    installPreferencesSymlink "$PREFERENCES_WORKSPACE_VSCODE/settings.json" "$PREFERENCES_VSCODE_LOCAL/settings.json"

    # keybindings.json
    installPreferencesSymlink "$PREFERENCES_VSCODE_CONFIG/keybindings.json" "$PREFERENCES_VSCODE_LOCAL/keybindings.json"
}

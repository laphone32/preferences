#!/usr/bin/env bash
# File: git/module_attribute.sh

function module_get_name() {
    echo "git"
}

function module_get_packages() {
    echo "git"
}

function module_get_gui_packages() {
    echo "git"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/git}"
    source "$PREFERENCES_DIR/git/common.sh"

    installPreferencesDir "$PREFERENCES_WORKSPACE_GIT"

    local gitVersion=$(git version 2>/dev/null | awk -F' ' '{print $3}')
    if [ -n "$gitVersion" ]; then
        local gitRepo="https://raw.githubusercontent.com/git/git/v${gitVersion}"
        curl -L "$gitRepo/contrib/completion/git-completion.bash" -o "$PREFERENCES_WORKSPACE_GIT_COMPLETION" 2>/dev/null || true
        curl -L "$gitRepo/contrib/completion/git-prompt.sh" -o "$PREFERENCES_WORKSPACE_GIT_PROMPT" 2>/dev/null || true
    fi

    PREFERENCES_DIR=$PREFERENCES_DIR envsubst '$PREFERENCES_DIR' < "$PREFERENCES_DIR/git/config.template" > "$PREFERENCES_WORKSPACE_GIT/config"
}

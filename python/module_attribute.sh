#!/usr/bin/env bash
# File: python/module_attribute.sh

function module_get_name() {
    echo "python"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/python}"
    source "$PREFERENCES_DIR/python/common.sh"
    source "$PREFERENCES_DIR/python/pvenv.sh"

    curl -L https://raw.githubusercontent.com/google/styleguide/gh-pages/pylintrc -o "$PREFERENCES_WORKSPACE_PYTHON_PYLINTRC" 2>/dev/null || true

    installPreferencesSudoSymlink "$PREFERENCES_WORKSPACE_PYTHON_PYLINTRC" $HOME/.config/pylintrc

    pythonVenvCreateOnce '_preferences_default' "$PREFERENCES_WORKSPACE_PYTHON"
}

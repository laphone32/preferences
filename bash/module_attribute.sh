#!/usr/bin/env bash
# File: bash/module_attribute.sh

source $PREFERENCES_DIR/bash/common.sh

function module_get_name() {
    echo "bash"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/bash}"
    source "$PREFERENCES_DIR/bash/common.sh"

    local install="export PREFERENCES_DIR='$PREFERENCES_DIR'
[[ -s \"\$PREFERENCES_DIR/bash/bashrc_loader\" ]] && source \"\$PREFERENCES_DIR/bash/bashrc_loader\""

    local bashProfileName="$HOME/.bashrc"
    if [ ! -f "$bashProfileName" ]; then
        bashProfileName="$HOME/.bash_profile"
    fi

    if [ -f "$bashProfileName" ]; then
        echo "install to $bashProfileName"
        installPreferencesSection "$bashProfileName" 'laphone preferences' "$install"
    else
        echo "Cannot find neither .bashrc nor .bash_profile"
    fi


    installPreferencesDir "$PREFERENCES_WORKSPACE_BASH"
    # Ahead-of-Time (AOT) Bashrc compilation
    compilePreferencesBashrc

    case $PREFERENCES_OS in
        'Darwin')
            if command -v brew &>/dev/null; then
                brew shellenv > "$PREFERENCES_WORKSPACE_BASH/brew_env.sh" 2>/dev/null || true
            elif [ -f "/opt/homebrew/bin/brew" ]; then
                /opt/homebrew/bin/brew shellenv > "$PREFERENCES_WORKSPACE_BASH/brew_env.sh" 2>/dev/null || true
            elif [ -f "/usr/local/bin/brew" ]; then
                /usr/local/bin/brew shellenv > "$PREFERENCES_WORKSPACE_BASH/brew_env.sh" 2>/dev/null || true
            fi
            installPreferencesSymlink "$PREFERENCES_DIR/bash/os/bashrc_macos" "$PREFERENCES_WORKSPACE_BASH/os.sh"
            ;;
        'Linux')
            installPreferencesSymlink "$PREFERENCES_DIR/bash/os/bashrc_linux" "$PREFERENCES_WORKSPACE_BASH/os.sh"
            ;;
        *)
            ;;
    esac
}

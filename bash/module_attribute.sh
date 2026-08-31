#!/usr/bin/env bash
# File: bash/module_attribute.sh

source $PREFERENCES_DIR/bash/common.sh

function module_get_name() {
    echo "bash"
}

function module_get_packages() {
    if [ "$PREFERENCES_OS" == "Darwin" ]; then
        echo "gls gsed"
    fi
}

function module_get_gui_packages() {
    if [ "$PREFERENCES_OS" == "Darwin" ]; then
        echo "gls gsed"
    fi
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


    # Ahead-of-Time (AOT) Bashrc compilation
    compilePreferencesBashrc

    case $PREFERENCES_OS in
        'Darwin')
            installPreferencesSymlink "$PREFERENCES_DIR/bash/os/bashrc_macos" "$PREFERENCES_WORKSPACE_BASH/os.sh"
            ;;
        'Linux')
            installPreferencesSymlink "$PREFERENCES_DIR/bash/os/bashrc_linux" "$PREFERENCES_WORKSPACE_BASH/os.sh"
            ;;
        *)
            ;;
    esac
}

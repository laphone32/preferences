#!/usr/bin/env bash
# File: vim/module_attribute.sh

function module_get_name() {
    echo "vim"
}

function module_get_packages() {
    echo "vim rg"
}

function module_get_gui_packages() {
    echo "gvim rg"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/vim}"

    # vim
    installPreferencesDir "$HOME/.vim"

    # Ideavim
    installPreferencesSymlink "$modDir/ideavimrc" "$HOME/.ideavimrc"

    # Pre-install vim plugins
    if command -v vim &> /dev/null; then
        echo "Installing Vim plugins..."
        vim -u "$modDir/vimrc" --not-a-term +PlugInstall +qall &> /dev/null || true
    fi
}

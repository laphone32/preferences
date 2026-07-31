#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"

# vim
installPreferencesDir $HOME/.vim

# Ideavim
installPreferencesSymlink $PREFERENCES_DIR/vim/ideavimrc $HOME/.ideavimrc

# Pre-install vim plugins
if command -v vim &> /dev/null; then
    echo "Installing Vim plugins..."
    vim -u "$PREFERENCES_DIR/vim/vimrc" --not-a-term +PlugInstall +qall &> /dev/null || true
fi



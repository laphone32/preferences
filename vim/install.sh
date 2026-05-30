#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"

# vim
installPreferencesDir $HOME/.vim

# Ideavim
installPreferencesSymlink $PREFERENCES_DIR/vim/ideavimrc $HOME/.ideavimrc


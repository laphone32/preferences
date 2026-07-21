#!/usr/bin/env bash

declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["7z"]="sevenzip unar"
)

function packageManagerInstall {
    local packages=("$@")
    local failed=0
    for pkg in "${packages[@]}"; do
        echo "Installing $pkg..."
        if ! brew install "$pkg"; then
            echo "Trying as cask: $pkg"
            if ! brew install --cask "$pkg"; then
                echo "Failed to install $pkg via brew"
                failed=1
            fi
        fi
    done
    if [ $failed -ne 0 ]; then return 1; fi
    if echo "${packages[@]}" | grep -q "sevenzip"; then
        local brew_bin
        brew_bin="$(brew --prefix)/bin"
        if [ -f "$brew_bin/7zz" ] && [ ! -f "$brew_bin/7z" ]; then
            echo "Creating symlink for 7z -> 7zz in $brew_bin"
            ln -sf 7zz "$brew_bin/7z"
        fi
    fi
}

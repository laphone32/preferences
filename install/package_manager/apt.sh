#!/usr/bin/env bash

# Package name conversions for apt
declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["node"]="nodejs"
    ["7z"]="7zip 7zip-rar"
    ["gvim"]="vim-gtk3"
    ["fcitx5"]="fcitx5 fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-qt5 fcitx5-chewing fcitx5-mozc"
)

# Installation command execution for apt
function packageManagerInstall {
    local packages=("$@")
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
}

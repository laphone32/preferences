#!/usr/bin/env bash

# Package name conversions for apt
declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["node"]="nodejs"
    ["7z"]="7zip 7zip-rar"
)

# Installation command execution for apt
function packageManagerInstall {
    local packages=("$@")
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
}

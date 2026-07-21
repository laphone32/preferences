#!/usr/bin/env bash

declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["node"]="nodejs"
    ["7z"]="7zip"
    ["surfshark"]="surfshark-client"
)

function packageManagerInstall {
    local packages=("$@")
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

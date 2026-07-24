#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/aur.sh"

function packageManagerInstall {
    local packages=("$@")
    sudo pacman -S --needed --noconfirm "${packages[@]}" && aurPostInstall "${packages[@]}"
}


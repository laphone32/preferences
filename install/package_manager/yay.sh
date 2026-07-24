#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/aur.sh"

function packageManagerInstall {
    local packages=("$@")
    yay -S --noconfirm --needed "${packages[@]}" && aurPostInstall "${packages[@]}"
}


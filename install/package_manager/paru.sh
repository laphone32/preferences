#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/aur.sh"

function packageManagerInstall {
    local packages=("$@")
    paru -S --noconfirm --needed "${packages[@]}" && aurPostInstall "${packages[@]}"
}


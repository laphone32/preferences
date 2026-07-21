#!/usr/bin/env bash

declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["npm"]=""
    ["7z"]="7zip"
)

function packageManagerInstall {
    local packages=("$@")
    local failed=0
    for pkg in "${packages[@]}"; do
        sudo snap install "$pkg" --classic || failed=1
    done
    return $failed
}

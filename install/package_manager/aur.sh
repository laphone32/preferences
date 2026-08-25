#!/usr/bin/env bash

declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["node"]="nodejs"
    ["7z"]="7zip"
    ["surfshark"]="surfshark-client"
    ["docker"]="docker docker-compose containerd"
    ["fcitx5"]="fcitx5-im fcitx5-chewing fcitx5-mozc"
)

function aurPostInstall {
    local packages=("$@")
    if [[ " ${packages[*]} " =~ " docker " ]]; then
        enablePreferencesSystemdSystemService "docker"
    fi
}


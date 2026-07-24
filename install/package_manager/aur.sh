#!/usr/bin/env bash

declare -g -A packageNameMap=(
    ["rg"]="ripgrep"
    ["node"]="nodejs"
    ["7z"]="7zip"
    ["surfshark"]="surfshark-client"
    ["docker"]="docker docker-compose containerd"
)

function aurPostInstall {
    local packages=("$@")
    if [[ " ${packages[*]} " =~ " docker " ]]; then
        sudo systemctl enable --now docker
    fi
}


#!/usr/bin/env bash

# Ubuntu-specific overrides for apt
packageNameMap["kitty"]=""
packageNameMap["docker"]="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

function setupDockerAptRepo {
    if [ ! -f /etc/apt/keyrings/docker.asc ] || [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        echo "Setting up official Docker APT repository..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        local codename
        codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
    fi
}

function packageManagerInstall {
    local packages=("$@")
    if [[ " ${packages[*]} " =~ " docker-ce " ]]; then
        setupDockerAptRepo
    fi
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
}


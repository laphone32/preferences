#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/docker/common.sh

installPreferencesDir $PREFERENCES_WORKSPACE_DOCKER

if command -v docker &> /dev/null; then
    docker completion bash > "$PREFERENCES_WORKSPACE_DOCKER_COMPLETION" 2>/dev/null || true
    if getent group docker >/dev/null && ! id -nG "$USER" | grep -qw "docker"; then
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER" 2>/dev/null || true
    fi
fi
if command -v kubectl &> /dev/null; then
    kubectl completion bash > "$PREFERENCES_WORKSPACE_DOCKER_KUBECTL_COMPLETION" 2>/dev/null || true
fi



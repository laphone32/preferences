#!/usr/bin/env bash
# File: docker/module_attribute.sh

function module_get_name() {
    echo "docker"
}

function module_get_packages() {
    echo "docker"
}

function module_get_gui_packages() {
    echo "docker"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/docker}"
    source "$PREFERENCES_DIR/docker/common.sh"

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
}

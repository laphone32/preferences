#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/docker/common.sh

installPreferencesDir $PREFERENCES_WORKSPACE_DOCKER

if command -v docker &> /dev/null; then
    docker completion bash > "$PREFERENCES_WORKSPACE_DOCKER_COMPLETION"
fi
if command -v kubectl &> /dev/null; then
    kubectl completion bash > "$PREFERENCES_WORKSPACE_DOCKER_KUBECTL_COMPLETION"
fi


#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/docker/common.sh

installPreferencesDir $PREFERENCES_WORKSPACE_DOCKER

docker completion bash > "$PREFERENCES_WORKSPACE_DOCKER_COMPLETION"
kubectl completion bash > "$PREFERENCES_WORKSPACE_DOCKER_KUBECTL_COMPLETION"


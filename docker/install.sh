#!/usr/bin/env bash

source $PREFERENCES_DIR/docker/common.sh

mkdir -p $PREFERENCES_WORKSPACE_DOCKER

docker completion bash > "$PREFERENCES_WORKSPACE_DOCKER_COMPLETION"
kubectl completion bash > "$PREFERENCES_WORKSPACE_DOCKER_KUBECTL_COMPLETION"


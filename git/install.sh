#!/usr/bin/env bash

if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi

source $PREFERENCES_DIR/git/common.sh

mkdir -p $PREFERENCES_WORKSPACE_GIT

GIT_REPO="https://raw.githubusercontent.com/git/git/v$(git version | awk -F' ' '{print $3}')"

curl -L "$GIT_REPO/contrib/completion/git-completion.bash" -o "$PREFERENCES_WORKSPACE_GIT_COMPLETION"
curl -L "$GIT_REPO/contrib/completion/git-prompt.sh" -o "$PREFERENCES_WORKSPACE_GIT_PROMPT"

PREFERENCES_DIR=$PREFERENCES_DIR envsubst '$PREFERENCES_DIR' < $PREFERENCES_DIR/git/config.template > $PREFERENCES_WORKSPACE_GIT/config


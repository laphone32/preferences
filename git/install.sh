#!/usr/bin/env bash

PREFERENCES_GIT=$PREFERENCES_DIR/git

ln -s $PREFERENCES_GIT/ignore $HOME/.gitignore
git config --global include.path $PREFERENCES_GIT/config


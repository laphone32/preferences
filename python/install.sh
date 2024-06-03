#!/usr/bin/env bash

source $PREFERENCES_DIR/python/common.sh

mkdir -p $PREFERENCES_WORKSPACE_PYTHON

curl -L https://raw.githubusercontent.com/google/styleguide/gh-pages/pylintrc -o $PREFERENCES_WORKSPACE_PYTHON_PYLINTRC


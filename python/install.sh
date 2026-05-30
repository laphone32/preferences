#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/python/common.sh
source $PREFERENCES_DIR/python/pvenv.sh

installPreferencesDir $PREFERENCES_WORKSPACE_PYTHON

curl -L https://raw.githubusercontent.com/google/styleguide/gh-pages/pylintrc -o $PREFERENCES_WORKSPACE_PYTHON_PYLINTRC

pythonVenvCreateOnce '_preferences_default' $PREFERENCES_WORKSPACE_PYTHON


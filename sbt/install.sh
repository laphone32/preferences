#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../util/bootstrap.sh"
source $PREFERENCES_DIR/sbt/common.sh

installPreferencesDir $PREFERENCES_WORKSPACE_SBT_GLOBAL_BASE
installPreferencesDir $PREFERENCES_WORKSPACE_SBT_COURSIER_CACHE
installPreferencesDir $PREFERENCES_WORKSPACE_SBT_IVY_CACHE

installPreferencesSymlink $PREFERENCES_DIR/sbt/global.sbt $PREFERENCES_WORKSPACE_SBT_GLOBAL_BASE/global-preferences.sbt


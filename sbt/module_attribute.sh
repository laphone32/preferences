#!/usr/bin/env bash
# File: sbt/module_attribute.sh

function module_get_name() {
    echo "sbt"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/sbt}"
    source "$PREFERENCES_DIR/sbt/common.sh"

    installPreferencesDir "$PREFERENCES_WORKSPACE_SBT_GLOBAL_BASE"
    installPreferencesDir "$PREFERENCES_WORKSPACE_SBT_COURSIER_CACHE"
    installPreferencesDir "$PREFERENCES_WORKSPACE_SBT_IVY_CACHE"

    installPreferencesSymlink "$PREFERENCES_DIR/sbt/global.sbt" "$PREFERENCES_WORKSPACE_SBT_GLOBAL_BASE/global-preferences.sbt"
}

#!/usr/bin/env bash

source $PREFERENCES_DIR/sbt/common.sh

mkdir -p $PREFERENCES_WORKSPACE_SBT_GLOBAL_BASE
mkdir -p $PREFERENCES_WORKSPACE_SBT_COURSIER_CACHE
mkdir -p $PREFERENCES_WORKSPACE_SBT_IVY_CACHE

ln -sf $PREFERENCES_DIR/sbt/global.sbt $PREFERENCES_WORKSPACE_SBT_GLOBAL_BASE/global-preferences.sbt


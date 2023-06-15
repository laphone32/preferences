#!/usr/bin/env bash

source $PREFERENCES_DIR/sbt/common.sh

mkdir -p $_preferencesSbtGlobalBase
mkdir -p $_preferencesSbtCoursierCache
mkdir -p $_preferencesSbtIvyCache

ln -sf $PREFERENCES_DIR/sbt/global.sbt $_preferencesSbtGlobalBase/global-preferences.sbt


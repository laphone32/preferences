#!/usr/bin/env bash

source $PREFERENCES_DIR/sbt/common.sh

mkdir -p $_XDGCacheDir
mkdir -p $HOME/.sbt/1.0

ln -sf $PREFERENCES_DIR/sbt/global.sbt $HOME/.sbt/1.0/global.sbt


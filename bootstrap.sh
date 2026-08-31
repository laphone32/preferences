#!/usr/bin/env bash
# File: bootstrap.sh
# Central bootstrapper for the preferences project.
# Sourcing this file automatically:
# 1. Calculates PREFERENCES_DIR dynamically relative to this script.
# 2. Configures default PATH fallback.
# 3. Loads core foundation libraries from bash/share/bash and install/share/bash.

[[ "${_PREFERENCES_BOOTSTRAP_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_BOOTSTRAP_SOURCED=yes

# 1. Calculate PREFERENCES_DIR dynamically (always repo root)
export PREFERENCES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PREFERENCES_WORKSPACE="${PREFERENCES_WORKSPACE:-$PREFERENCES_DIR/.workspace}"

# 2. Standard robust fallback PATH and Python workspace PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"
export PYTHONPATH="$PREFERENCES_WORKSPACE/share/python:$PREFERENCES_DIR${PYTHONPATH:+:$PYTHONPATH}"

# 3. Source core foundation libraries
source "$PREFERENCES_DIR/bash/share/bash/environment.sh"
source "$PREFERENCES_DIR/bash/share/bash/utils.sh"
source "$PREFERENCES_DIR/bash/share/bash/override.sh"
source "$PREFERENCES_DIR/system/share/bash/systemd.sh"
source "$PREFERENCES_DIR/install/share/bash/manifest.sh"
source "$PREFERENCES_DIR/install/share/bash/install.sh"
source "$PREFERENCES_DIR/install/share/bash/module.sh"

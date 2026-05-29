#!/usr/bin/env bash

# This is the central bootstrapper for all scripts in the preferences project.
# Sourcing this file automatically:
# 1. Calculates the root PREFERENCES_DIR dynamically.
# 2. Configures a robust standard environment PATH.
# 3. Loads environment configuration and utility functions.

# Prevent multiple sourcing
[[ "${_PREFERENCES_UTIL_BOOTSTRAP_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_BOOTSTRAP_SOURCED=yes

# 1. Calculate PREFERENCES_DIR dynamically relative to this script's location (always <root>/util/bootstrap.sh)
export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# 2. Configure standard robust PATH (essential for cron/non-interactive shell sessions)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

# 3. Source environment and utils
source "$PREFERENCES_DIR/util/environment.sh"
source "$PREFERENCES_DIR/util/utils.sh"

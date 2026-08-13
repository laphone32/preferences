#!/usr/bin/env bash
# File: keyd/required_fallback.sh

# The global installer verifies installation by checking `command -v <pkg>`.
# Since we added 'keyd' to required.sh, it expects a `keyd` binary.
# Debian renames the binary to `keyd.rvaiya`. We satisfy the installer check here.
source "$PREFERENCES_DIR/util/override.sh"

if ! command -v keyd &> /dev/null && command -v keyd.rvaiya &> /dev/null; then
    wrap '' 'keyd.rvaiya' 'keyd'
fi

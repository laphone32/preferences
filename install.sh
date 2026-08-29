#!/usr/bin/env bash

# 1. Deterministic Bootstrap from any directory
source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"

# 2. Package Management verification
sourceShare install package.sh
if ! installNecessaryPackages "$@"; then
    echo "❌ Error: Required package installation incomplete. Aborting installation."
    exit 1
fi

# 3. Initialize workspace and setup Python symlinks & PATH aggregation
installPreferencesDir "$(workspace '')"

# 4. Ahead-of-Time (AOT) Bashrc Compilation
compilePreferencesBashrc

# 5. Module Installation Execution
if [ "$#" -ge 1 ]; then
    for module in "$@"; do
        installModule "$PREFERENCES_DIR/$module"
    done
else
    installAllModules
fi

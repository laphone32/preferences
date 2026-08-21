#!/usr/bin/env bash
# File: aws/module_attribute.sh

function module_get_name() {
    echo "aws"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/aws}"
    local PREFERENCES_WORKSPACE_AWS="$PREFERENCES_WORKSPACE/aws"

    case "$PREFERENCES_OS" in
        'Darwin')
            installPreferencesSymlink "$modDir/os/macos.sh" "$PREFERENCES_WORKSPACE_AWS/os.sh"
            ;;
        'Linux')
            installPreferencesSymlink "$modDir/os/linux.sh" "$PREFERENCES_WORKSPACE_AWS/os.sh"
            ;;
        *)
            ;;
    esac
}

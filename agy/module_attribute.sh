#!/usr/bin/env bash
# File: agy/module_attribute.sh

function module_get_name() {
    echo "agy"
}

function module_get_packages() {
    echo "sbx"
}

function module_get_gui_packages() {
    echo "sbx"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/agy}"
    source "$PREFERENCES_DIR/agy/common.sh"
}

#!/usr/bin/env bash
# File: install/module_attribute.sh

function module_get_name() {
    echo "install"
}

function module_get_packages() {
    echo "curl node npm 7z"
}

function module_get_gui_packages() {
    echo "curl node npm 7z surfshark spotify"
}

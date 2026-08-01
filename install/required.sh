#!/usr/bin/env bash

# Global required software
base_packages=('curl' 'node' 'npm' '7z')
packages+=("${base_packages[@]}")

# Additional desktop GUI software
gui_packages+=("${base_packages[@]}" 'surfshark' 'spotify')

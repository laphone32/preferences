#!/usr/bin/env bash
# File: install/share/bash/package.sh

source "${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}/bootstrap.sh" 2>/dev/null || true

# Detect package manager (priority: apt > paru > yay > pacman > brew > snap)
# Returns: PRIMARY,SECONDARY
function detectPackageManager {
    local managers=("apt-get" "paru" "yay" "pacman" "brew" "snap")
    local primary="none"
    local secondary="none"

    for pm in "${managers[@]}"; do
        if command -v "$pm" &> /dev/null; then
            local mapped_pm="$pm"
            if [ "$pm" == "apt-get" ]; then
                mapped_pm="apt"
            elif [ "$pm" == "pacman" ]; then
                if command -v paru &> /dev/null; then
                    mapped_pm="paru"
                elif command -v yay &> /dev/null; then
                    mapped_pm="yay"
                else
                    >&2 echo "Bootstrapping paru since pacman was detected but no AUR helper is present..."
                    sudo pacman -S --needed --noconfirm base-devel git >&2
                    git clone https://aur.archlinux.org/paru.git /tmp/paru-build >&2
                    (cd /tmp/paru-build && makepkg -si --noconfirm) >&2
                    rm -rf /tmp/paru-build >&2
                    mapped_pm="paru"
                fi
            fi

            if [ "$primary" == "$mapped_pm" ]; then
                continue
            fi

            if [ "$primary" == "none" ]; then
                primary="$mapped_pm"
            elif [ "$secondary" == "none" ]; then
                secondary="$mapped_pm"
                break
            fi
        fi
    done

    echo "$primary,$secondary"
}

function loadPackageManager {
    local pkgManager=$1
    unset packageNameMap
    unset -f packageManagerInstall 2>/dev/null || true
    declare -g -A packageNameMap=()

    local pkg_manager_dir="$PREFERENCES_DIR/install/package_manager"

    local base_script="$pkg_manager_dir/${pkgManager}.sh"
    if [ -f "$base_script" ]; then
        source "$base_script"
    fi

    local distro_script="$pkg_manager_dir/${pkgManager}_${PREFERENCES_DISTRO}.sh"
    if [ -f "$distro_script" ]; then
        source "$distro_script"
    fi
}

# Map an array of commands to their package names for the specific package manager
function mapPackages {
    local pkgManager=$1
    shift
    local packages=("$@")
    local mapped_packages=()

    loadPackageManager "$pkgManager"

    for cmd in "${packages[@]}"; do
        local mapped=""
        if [ ${packageNameMap[$cmd]+isset} ]; then
            mapped="${packageNameMap[$cmd]}"
        else
            mapped="$cmd"
        fi

        for p in $mapped; do
            if [ -n "$p" ]; then
                mapped_packages+=("$p")
            fi
        done
    done

    echo "${mapped_packages[@]}"
}

# Install packages using the detected package manager (batch install)
function installPackages {
    local pkgManager=$1
    shift
    local packages=("$@")

    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    echo "Installing packages using $pkgManager: ${packages[@]}"

    loadPackageManager "$pkgManager"

    if declare -f packageManagerInstall &>/dev/null; then
        packageManagerInstall "${packages[@]}"
    else
        if [ "$pkgManager" == "none" ]; then
            echo "Error: No supported package manager found. Please install packages manually: ${packages[@]}"
        else
            echo "Error: No packageManagerInstall handler found for package manager '$pkgManager'."
        fi
        return 1
    fi
}

function installPackageList {
    local list_name=$1
    shift
    local packages_to_map=("$@")

    if [ ${#packages_to_map[@]} -eq 0 ]; then
        return 0
    fi

    if [ "$PRIMARY_PKG_MANAGER" == "none" ]; then
        echo "Error: No primary package manager available."
        return 1
    fi

    local mapped_primary=($(mapPackages "$PRIMARY_PKG_MANAGER" "${packages_to_map[@]}"))

    if [ ${#mapped_primary[@]} -gt 0 ]; then
        echo "Installing $list_name via primary package manager ($PRIMARY_PKG_MANAGER)..."
        if ! installPackages "$PRIMARY_PKG_MANAGER" "${mapped_primary[@]}"; then
            echo "Failed to install $list_name with primary package manager."
            if [ "$SECONDARY_PKG_MANAGER" != "none" ]; then
                echo "Trying secondary package manager ($SECONDARY_PKG_MANAGER)..."
                local mapped_secondary=($(mapPackages "$SECONDARY_PKG_MANAGER" "${packages_to_map[@]}"))
                if [ ${#mapped_secondary[@]} -gt 0 ]; then
                    if ! installPackages "$SECONDARY_PKG_MANAGER" "${mapped_secondary[@]}"; then
                        echo "Failed to install $list_name with both primary and secondary package managers."
                        return 1
                    fi
                else
                    echo "No valid packages mapped for secondary package manager."
                    return 1
                fi
            else
                echo "Please install them manually."
                return 1
            fi
        fi
    fi
}

# Entry function to install all necessary packages across all modules
function installNecessaryPackages {
    local target_modules=("$@")

    IFS=',' read -r PRIMARY_PKG_MANAGER SECONDARY_PKG_MANAGER <<< "$(detectPackageManager)"

    echo "Detected primary package manager: $PRIMARY_PKG_MANAGER"
    echo "Detected secondary package manager: $SECONDARY_PKG_MANAGER"

    # Select target command list based on environment
    target_commands=()
    local envType="cli"
    isGuiEnvironment && envType="gui"

    if [ ${#target_modules[@]} -gt 0 ]; then
        echo "Targeted package check for modules: ${target_modules[*]}"
        for mod in "${target_modules[@]}"; do
            local modDir="$PREFERENCES_DIR/$mod"
            if isModule "$modDir"; then
                loadModuleAttributes "$modDir"
                local pkgs=""
                if [ "$envType" == "gui" ] && declare -f module_get_gui_packages &>/dev/null; then
                    pkgs=$(module_get_gui_packages)
                elif declare -f module_get_packages &>/dev/null; then
                    pkgs=$(module_get_packages)
                fi
                for p in $pkgs; do
                    [ -n "$p" ] && target_commands+=("$p")
                done
            fi
        done
    else
        if [ "$envType" == "gui" ]; then
            echo "GUI environment detected. Processing GUI target packages..."
            target_commands=($(collectAllModulePackages gui))
        else
            echo "Headless environment detected. Processing CLI target packages..."
            target_commands=($(collectAllModulePackages cli))
        fi
    fi

    # Check which packages are missing
    missing_commands=()
    for commandName in "${target_commands[@]}"; do
        if ! command -v "$commandName" &> /dev/null; then
            missing_commands+=("$commandName")
        fi
    done

    # Install missing packages in batch
    if [ ${#missing_commands[@]} -gt 0 ]; then
        installPackageList "packages" "${missing_commands[@]}"
    fi

    # Execute fallback scripts for still-missing packages
    runAllModuleFallbacks

    # Final verification
    still_missing=()
    echo ""
    echo "Verifying installations..."
    for commandName in "${target_commands[@]}"; do
        if ! command -v "$commandName" &> /dev/null; then
            echo "⚠ Error: $commandName is still not available after fallbacks. You may need to restart your shell or add it to PATH manually."
            still_missing+=("$commandName")
        else
            echo "✓ Successfully verified $commandName"
        fi
    done

    if [ ${#still_missing[@]} -gt 0 ]; then
        echo "Fatal: Some required packages failed to install: ${still_missing[*]}"
        return 1
    else
        echo "Required software all met"
        return 0
    fi
}

# Run directly if executed as a script rather than sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    installNecessaryPackages "$@" || exit 1
fi

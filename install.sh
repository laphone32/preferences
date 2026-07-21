#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/util/bootstrap.sh"


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

IFS=',' read -r PRIMARY_PKG_MANAGER SECONDARY_PKG_MANAGER <<< "$(detectPackageManager)"

echo "Detected primary package manager: $PRIMARY_PKG_MANAGER"
echo "Detected secondary package manager: $SECONDARY_PKG_MANAGER"

function loadPackageManager {
    local pkgManager=$1
    unset packageNameMap
    unset -f packageManagerInstall 2>/dev/null || true
    declare -g -A packageNameMap=()

    local base_script="$PREFERENCES_DIR/install/package_manager/${pkgManager}.sh"
    if [ -f "$base_script" ]; then
        source "$base_script"
    fi

    local distro_script="$PREFERENCES_DIR/install/package_manager/${pkgManager}_${PREFERENCES_DISTRO}.sh"
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

# Initialize arrays
packages=()
optional_packages=()

# Source global and module packages
for req_file in "$PREFERENCES_DIR"/*/required.sh; do
    if [ -f "$req_file" ]; then
        source "$req_file"
    fi
done

# Check which packages are missing
missing_commands=()
for commandName in "${packages[@]}"; do
    if ! command -v "$commandName" &> /dev/null; then
        missing_commands+=("$commandName")
    fi
done

missing_optional=()
for commandName in "${optional_packages[@]}"; do
    if ! command -v "$commandName" &> /dev/null; then
        missing_optional+=("$commandName")
    fi
done

function installPackageList {
    local list_name=$1
    local is_fatal=$2
    shift 2
    local packages_to_map=("$@")

    if [ ${#packages_to_map[@]} -eq 0 ]; then
        return 0
    fi

    if [ "$PRIMARY_PKG_MANAGER" == "none" ]; then
        echo "Error: No primary package manager available."
        if [ "$is_fatal" == "true" ]; then exit 1; else return 1; fi
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
                        if [ "$is_fatal" == "true" ]; then exit 1; else return 1; fi
                    fi
                else
                    echo "No valid packages mapped for secondary package manager."
                    if [ "$is_fatal" == "true" ]; then exit 1; else return 1; fi
                fi
            else
                echo "Please install them manually."
                if [ "$is_fatal" == "true" ]; then exit 1; else return 1; fi
            fi
        fi
    fi
}

# Install missing packages in batch
if [ ${#missing_commands[@]} -gt 0 ]; then
    installPackageList "packages" "true" "${missing_commands[@]}"
fi

# Install additional optional packages (GUI apps, etc.)
if [ "$PREFERENCES_SKIP_ADDITIONAL" != "1" ] && [ ${#missing_optional[@]} -gt 0 ]; then
    installPackageList "optional packages" "false" "${missing_optional[@]}"
fi

# Execute fallback scripts for still-missing packages
for fallback_file in "$PREFERENCES_DIR"/*/required_fallback.sh; do
    if [ -f "$fallback_file" ]; then
        source "$fallback_file"
    fi
done

# Final verification
still_missing=()
echo ""
echo "Verifying installations..."
for commandName in "${packages[@]}"; do
    if ! command -v "$commandName" &> /dev/null; then
        echo "⚠ Error: $commandName is still not available after fallbacks. You may need to restart your shell or add it to PATH manually."
        still_missing+=("$commandName")
    else
        echo "✓ Successfully verified $commandName"
    fi
done

if [ ${#still_missing[@]} -gt 0 ]; then
    echo "Fatal: Some required packages failed to install."
    exit 1
else
    echo "Required software all met"
fi

# workspace
installPreferencesDir "$(workspace '')"


# module installation
function echoAndSource {
    local arg=$1
    echo "source $arg"
    source $arg
}

if [ "$#" -ge 1 ]; then
    for module in "$@"; do
        echoAndSource "$PREFERENCES_DIR/$module/install.sh"
    done
else
    eachSubFile "$PREFERENCES_DIR" 'echoAndSource' 'install.sh'
fi

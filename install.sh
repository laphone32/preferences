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

# Map an array of commands to their package names for the specific package manager
function mapPackages {
    local pkgManager=$1
    shift
    local packages=("$@")
    local mapped_packages=()

    for cmd in "${packages[@]}"; do
        local mapped=""
        case $pkgManager in
            'apt')
                case $cmd in
                    'rg') mapped="ripgrep" ;;
                    'node') mapped="nodejs" ;;
                    '7z') mapped="7zip 7zip-rar" ;;
                    'kitty') mapped="" ;; # Skip it from apt
                    *) mapped="$cmd" ;;
                esac
                ;;
            'paru'|'yay')
                case $cmd in
                    'rg') mapped="ripgrep" ;;
                    'node') mapped="nodejs" ;;
                    '7z') mapped="7zip" ;;
                    'xtermcontrol') mapped="xtermcontrol" ;;
                    'surfshark') mapped="surfshark-client" ;;
                    *) mapped="$cmd" ;;
                esac
                ;;
            'brew')
                case $cmd in
                    'rg') mapped="ripgrep" ;;
                    '7z') mapped="sevenzip unar" ;;
                    *) mapped="$cmd" ;;
                esac
                ;;
            'snap')
                case $cmd in
                    'rg') mapped="ripgrep" ;;
                    'node') mapped="node" ;;
                    'npm')
                        >&2 echo "Note: npm is included with node, skipping separate installation"
                        mapped=""
                        ;;
                    '7z') mapped="7zip" ;;
                    *) mapped="$cmd" ;;
                esac
                ;;
            *)
                mapped="$cmd"
                ;;
        esac

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

    case $pkgManager in
        'apt')
            sudo apt-get update
            sudo apt-get install -y "${packages[@]}"
            ;;

        'paru')
            paru -S --noconfirm --needed "${packages[@]}"
            ;;
        'yay')
            yay -S --noconfirm --needed "${packages[@]}"
            ;;
        'brew')
            local failed=0
            for pkg in "${packages[@]}"; do
                echo "Installing $pkg..."
                if ! brew install "$pkg"; then
                    echo "Trying as cask: $pkg"
                    if ! brew install --cask "$pkg"; then
                        echo "Failed to install $pkg via brew"
                        failed=1
                    fi
                fi
            done
            if [ $failed -ne 0 ]; then return 1; fi
            if echo "${packages[@]}" | grep -q "sevenzip"; then
                local brew_bin
                brew_bin="$(brew --prefix)/bin"
                if [ -f "$brew_bin/7zz" ] && [ ! -f "$brew_bin/7z" ]; then
                    echo "Creating symlink for 7z -> 7zz in $brew_bin"
                    ln -sf 7zz "$brew_bin/7z"
                fi
            fi
            ;;
        'snap')
            local failed=0
            for pkg in "${packages[@]}"; do
                sudo snap install "$pkg" --classic || failed=1
            done
            return $failed
            ;;
        'none')
            echo "Error: No supported package manager found. Please install packages manually: ${packages[@]}"
            return 1
            ;;
    esac
}

# Initialize arrays
packages=()
optional_packages=()

# Source global and module packages
if [ -f "$PREFERENCES_DIR/packages.sh" ]; then
    source "$PREFERENCES_DIR/packages.sh"
fi
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

#!/usr/bin/env bash

PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $PREFERENCES_DIR/util/environment.sh
source $PREFERENCES_DIR/util/utils.sh


# Detect package manager (priority: apt > brew > snap)
function detectPackageManager {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v snap &> /dev/null; then
        echo "snap"
    else
        echo "none"
    fi
}

PACKAGE_MANAGER=$(detectPackageManager)
echo "Detected package manager: $PACKAGE_MANAGER"

# Map command name to package name for specific package manager
function mapPackageName {
    local commandName=$1
    local pkgManager=$2

    case $pkgManager in
        'apt')
            case $commandName in
                'rg') echo "ripgrep" ;;
                'node') echo "nodejs" ;;
                *) echo "$commandName" ;;
            esac
            ;;
        'brew')
            case $commandName in
                'rg') echo "ripgrep" ;;
                *) echo "$commandName" ;;
            esac
            ;;
        'snap')
            case $commandName in
                'rg') echo "ripgrep" ;;
                'node') echo "node" ;;
                *) echo "$commandName" ;;
            esac
            ;;
        *)
            echo "$commandName"
            ;;
    esac
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
        'brew')
            brew install "${packages[@]}"
            ;;
        'snap')
            for pkg in "${packages[@]}"; do
                sudo snap install "$pkg" --classic
            done
            ;;
        'none')
            echo "Error: No supported package manager found. Please install packages manually: ${packages[@]}"
            return 1
            ;;
    esac
}

# Required software (unified for all platforms)
requirements=('curl' 'git' 'node' 'npm' 'rg' 'vim' 'xtermcontrol')

# Check which packages are missing
missing_commands=()
for commandName in ${requirements[@]}; do
    if ! command -v $commandName &> /dev/null; then
        echo "Required software [$commandName] not found."
        missing_commands+=("$commandName")
    else
        echo "✓ $commandName is already installed"
    fi
done

# Install missing packages in batch
if [ ${#missing_commands[@]} -gt 0 ]; then
    if [ "$PACKAGE_MANAGER" == "none" ]; then
        echo "Error: No package manager available. Please install the following requirements manually: ${missing_commands[@]}"
        exit 1
    fi

    # Map command names to package names
    packages_to_install=()
    for cmd in "${missing_commands[@]}"; do
        pkg=$(mapPackageName "$cmd" "$PACKAGE_MANAGER")
        # Skip npm for snap as it's included with node
        if [ "$PACKAGE_MANAGER" == "snap" ] && [ "$cmd" == "npm" ]; then
            echo "Note: npm is included with node, skipping separate installation"
            continue
        fi
        packages_to_install+=("$pkg")
    done

    if [ ${#packages_to_install[@]} -gt 0 ]; then
        if ! installPackages "$PACKAGE_MANAGER" "${packages_to_install[@]}"; then
            echo "Failed to install packages. Please install them manually."
            exit 1
        fi

        # Verify installations
        echo ""
        echo "Verifying installations..."
        for commandName in "${missing_commands[@]}"; do
            if ! command -v $commandName &> /dev/null; then
                echo "⚠ Warning: $commandName is still not available. You may need to restart your shell or add it to PATH manually."
            else
                echo "✓ Successfully installed $commandName"
            fi
        done
    fi
fi

echo "Required software all met"

# workspace
mkdir -p "$(workspace '')"


# module installation
function echoAndSource {
    local arg=$1
    echo "source $arg"
    source $arg
}

if [ "$#" -ge 1 ]; then
    echoAndSource $PREFERENCES_DIR/$1/install.sh
else
    eachSubFile "$PREFERENCES_DIR" 'echoAndSource' 'install.sh'
fi

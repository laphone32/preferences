#!/usr/bin/env bash
# File: fonts/module_attribute.sh

function module_get_name() {
    echo "fonts"
}

function module_install() {
    local modDir="${1:-$PREFERENCES_DIR/fonts}"
    source "$PREFERENCES_DIR/fonts/common.sh"

    installPreferencesDir "$PREFERENCES_WORKSPACE_FONTS"

    local font_install_folder=""
    case $PREFERENCES_OS in
        'Darwin')
            font_install_folder="$HOME/Library/Fonts"
            ;;
        'Linux')
            font_install_folder="$HOME/.local/share/fonts"
            ;;
        *)
            ;;
    esac

    if [ -z "$font_install_folder" ]; then
        echo "⚠ Unsupported OS ($PREFERENCES_OS) for fonts installation."
        return 0
    fi

    installPreferencesDir "$font_install_folder"

    local any_font_updated=false
    declare -A repo_version_cache=()

    function get_cached_release {
        local from=$1
        if [ -z "${repo_version_cache[$from]}" ]; then
            local user="${from%/*}"
            local repo="${from#*/}"
            repo_version_cache[$from]=$(githubLatestRelease "$user" "$repo" 2>/dev/null)
        fi
        echo "${repo_version_cache[$from]}"
    }

    function deploy_font {
        local from=$1
        local keyword=$2
        local download_extension=$3

        local latest_version=$(get_cached_release "$from")
        local installed_fontname="$font_install_folder/preferences_installed_font_$keyword"
        local version_file="$installed_fontname/.version"

        # Check if already installed and version matches
        if [ -n "$latest_version" ] && [ -d "$installed_fontname" ] && [ -f "$version_file" ]; then
            local current_version=$(cat "$version_file" 2>/dev/null)
            if [ "$current_version" == "$latest_version" ]; then
                echo "✓ Font '$keyword' ($current_version) is up to date."
                return 0
            fi
        fi

        # If offline/unable to retrieve release tag but font is already installed, skip
        if [ -z "$latest_version" ] && [ -d "$installed_fontname" ]; then
            echo "✓ Font '$keyword' is already installed."
            return 0
        fi

        echo "⬇ Updating/Installing font '$keyword'${latest_version:+ ($latest_version)}..."

        local download_url=""
        if [ -n "$latest_version" ]; then
            download_url="https://github.com/$from/releases/download/$latest_version/$keyword$download_extension"
        else
            download_url=$(curl -s "https://api.github.com/repos/$from/releases/latest" | grep "$keyword.*$download_extension" | grep browser_download_url | cut -d : -f 2,3 | tr -d ' "' | head -n 1)
        fi

        if [ -n "$download_url" ]; then
            local font_filename=$(basename "$download_url")
            local local_file="$PREFERENCES_WORKSPACE_FONTS/$font_filename"
            local workspace_font_dir="$PREFERENCES_WORKSPACE_FONTS/$keyword"

            if ! curl -f -L "$download_url" -o "$local_file"; then
                echo "❌ Failed to download font '$keyword' from $download_url"
                return 1
            fi

            mkdir -p "$workspace_font_dir"
            tar -xf "$local_file" -C "$workspace_font_dir"

            rm -rf "$installed_fontname"
            installPreferencesFontDir "$installed_fontname"
            cp -r "$workspace_font_dir/." "$installed_fontname"

            if [ -n "$latest_version" ]; then
                echo "$latest_version" > "$version_file"
                echo "$latest_version" > "$PREFERENCES_WORKSPACE_FONTS/.version_$keyword"
            fi

            any_font_updated=true
            echo "✓ Successfully installed font '$keyword'."
        fi
    }

    deploy_font 'ryanoasis/nerd-fonts' 'DejaVuSansMono' '.tar.xz'
    deploy_font 'ryanoasis/nerd-fonts' 'JetBrainsMono' '.tar.xz'
    deploy_font 'ryanoasis/nerd-fonts' 'CodeNewRoman' '.tar.xz'

    if [ "$any_font_updated" == "true" ] && command -v fc-cache &>/dev/null; then
        echo "🔄 Updating font cache..."
        fc-cache -f
    fi
}

#!/usr/bin/env bash

source $PREFERENCES_DIR/util/utils.sh

PREFERENCES_WORKSPACE_FONTS=$PREFERENCES_WORKSPACE/fonts
mkdir -p $PREFERENCES_WORKSPACE_FONTS

font_install_folder="$HOME/.local/share/font"
case $PREFERENCES_OS in
    'Darwin')
        font_install_folder="$HOME/Library/Fonts"
        ;;
    'Linux')
        font_install_folder="$HOME/.local/share/font"
        ;;
    *)
        ;;
esac

mkdir -p $font_install_folder

function deploy_font {
    local from=$1
    local keyword=$2
    local download_extension=$3

    local download_url=$(curl -s https://api.github.com/repos/$from/releases/latest | grep "$keyword.*$download_extension" | grep browser_download_url | cut -d : -f 2,3 | tr -d \")
    local font_filename=$(basename $download_url)
    local font_name=${font_filename%$download_extension}

    local local_file=$PREFERENCES_WORKSPACE_FONTS/$font_filename

    curl -L $download_url -o $local_file

    local workspace_font_dir=$PREFERENCES_WORKSPACE_FONTS/$font_name

    mkdir -p $workspace_font_dir
    tar -xf $local_file -C $workspace_font_dir

    local installed_fontname=$font_install_folder/preferences_installed_font_$font_name
    rm -rf $installed_fontname
    cp -r $workspace_font_dir $installed_fontname
}

#deploy_font 'dejavu-fonts/dejavu-fonts' 'dejavu-fonts-ttf-' '.tar.bz2'
deploy_font 'ryanoasis/nerd-fonts' 'DejaVuSansMono' '.tar.xz'

fc-cache -f


#!/usr/bin/env bash

source $PREFERENCES_DIR/util/utils.sh

PREFERENCES_WORKSPACE_FONTS=$PREFERENCES_WORKSPACE/fonts
mkdir -p $PREFERENCES_WORKSPACE_FONTS

download_extension=".tar.bz2"
download_url=$(curl -s https://api.github.com/repos/dejavu-fonts/dejavu-fonts/releases/latest | grep "dejavu-fonts-ttf-.*$download_extension" | grep download_url | cut -d : -f 2,3 | tr -d \")
font_filename=$(basename $download_url)
font_name=${font_filename%$download_extension}


local_file=$PREFERENCES_WORKSPACE_FONTS/$font_filename

curl -L $download_url -o $local_file
tar -xvjf $local_file -C $PREFERENCES_WORKSPACE_FONTS

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
cp -r $PREFERENCES_WORKSPACE_FONTS/$font_name/ $font_install_folder/
fc-cache -f -v


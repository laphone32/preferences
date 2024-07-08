#!/usr/bin/env bash

source $PREFERENCES_DIR/util/utils.sh
source $PREFERENCES_DIR/kitty/common.sh

mkdir -p $PREFERENCES_KITTY_LOCAL
mkdir -p $PREFERENCES_WORKSPACE_KITTY

# shell
bash_shell=$(which bash)
cat << EOT > $PREFERENCES_WORKSPACE_KITTY/device.conf
shell ${bash_shell} --login
EOT

ln -sf $PREFERENCES_WORKSPACE_KITTY/device.conf $PREFERENCES_KITTY_LOCAL/device.conf

# color scheme
mkdir -p $PREFERENCES_WORKSPACE_KITTY/color-theme
function dump_theme {
    kitty +kitten themes --dump-theme $1 > $PREFERENCES_WORKSPACE_KITTY/color-theme/$2.conf
}
dump_theme 'Chalk' 'default'
dump_theme 'Nord' 'vim'
dump_theme 'Vaughn' 'remote'
dump_theme 'Earthsong' 'container'
dump_theme 'Solarized Darcula' 'uat'
dump_theme 'Red Alert' 'prod'

ln -sf $PREFERENCES_WORKSPACE_KITTY/color-theme/default.conf $PREFERENCES_KITTY_LOCAL/theme.conf

# os specific
case $PREFERENCES_OS in
    'Darwin')
        ln -sf $PREFERENCES_DIR/kitty/os/kitty_macos.conf $PREFERENCES_KITTY_LOCAL/os.conf
        ;;
    'Linux')
        ln -sf $PREFERENCES_DIR/kitty/os/kitty_linux.conf $PREFERENCES_KITTY_LOCAL/os.conf
        ;;
    *)
        ;;
esac

# fonts
ln -sf $PREFERENCES_KITTY/fonts/default.conf $PREFERENCES_KITTY_LOCAL/fonts.conf

# watcher
cp $PREFERENCES_KITTY/config/watcher.py $PREFERENCES_WORKSPACE_KITTY/watcher.py

kitty_install="\
preferences_dir=\'$PREFERENCES_DIR\'\\
kitty_config=\'$PREFERENCES_KITTY_LOCAL\'\
"
updateOrInsertSection "$PREFERENCES_WORKSPACE_KITTY/watcher.py" 'Preferences variables' "$kitty_install"
ln -sf $PREFERENCES_WORKSPACE_KITTY/watcher.py $PREFERENCES_KITTY_LOCAL/watcher.py

# configs
ln -sf $PREFERENCES_KITTY/config/kitty.conf $PREFERENCES_KITTY_LOCAL/kitty.conf


#!/bin/bash

headMark='### laphone preferences ###'
footMark='### end of laphone preferences ###'

leadLine="^$headMark\$"
tailLine="^$footMark\$"

install="\
export PREFERENCES_DIR=$PREFERENCES_DIR\\n\
source $PREFERENCES_DIR/bash/bashrc\
"

bashProfileName="$HOME/.bashrc"
if [ ! -f $bashProfileName ]; then
    bashProfileName="$HOME/.bash_profile"
fi

bashProfileNameBackup="$bashProfileName.bak"

if [ -f $bashProfileName ]; then

    sed -e "/$leadLine/,/$tailLine/{h; /$leadLine/{p; a \\$install
    }; /$tailLine/p; d };\${x;/^$/{s||$headMark\\n$install\\n$footMark\\n|;H};x}" $bashProfileName > $bashProfileNameBackup && mv $bashProfileNameBackup $bashProfileName

else
    echo "Cannot find neither .bashrc nor .bash_profile"
fi


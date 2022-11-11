#!/bin/bash

export PREFERENCES_TERM=$PREFERENCES_DIR/term

# TERM
if [[ "$OSTYPE" == "darwin"* ]]; then
    source $PREFERENCES_TERM/iterm2.sh
else
    source $PREFERENCES_TERM/xtermcontrol.sh
fi
setTerm default




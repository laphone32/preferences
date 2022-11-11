#!/bin/bash

export PREFERENCES_TERM=$PREFERENCES_DIR/term

PREFERENCES_TERM_COLOR_DIR=$PREFERENCES_TERM/color
PREFERENCES_TERM_FONT_DIR=$PREFERENCES_TERM/font

# TERM
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$TERM_PROGRAM" == "iTerm"* ]]; then
        source $PREFERENCES_TERM_COLOR_DIR/iterm2.sh
        source $PREFERENCES_TERM_FONT_DIR/iterm2.sh
    else
        source $PREFERENCES_TERM_COLOR_DIR/xtermcontrol.sh
        source $PREFERENCES_TERM_FONT_DIR/apple_terminal.sh
    fi
else
    source $PREFERENCES_TERM_COLOR_DIR/xtermcontrol.sh
fi

source $PREFERENCES_TERM/wrapper.sh
setTerm default

#!/bin/bash

export PREFERENCES_TERM=$PREFERENCES_DIR/term

PREFERENCES_TERM_COLOR_DIR=$PREFERENCES_TERM/color
PREFERENCES_TERM_FONT_DIR=$PREFERENCES_TERM/font

# TERM
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$TERM_PROGRAM" == "iTerm"* ]]; then
        source $PREFERENCES_TERM_COLOR_DIR/iterm2.sh
    else
        source $PREFERENCES_TERM_COLOR_DIR/xtermcontrol.sh
        source $PREFERENCES_TERM_FONT_DIR/apple_terminal.sh
    fi
else
    source $PREFERENCES_TERM_COLOR_DIR/xtermcontrol.sh

    terminal=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))")

    case $terminal in
        "gnome-terminal"*)
            source $PREFERENCES_TERM_FONT_DIR/gnome_terminal.sh
            ;;
        "kgx")
            ;;
        *)
            ;;
    esac
fi

source $PREFERENCES_TERM/wrapper.sh
setTerm default

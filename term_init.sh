#!/bin/bash

export PREFERENCES_TERM=$PREFERENCES_DIR/term

PREFERENCES_TERM_COLOR_DIR=$PREFERENCES_TERM/color
PREFERENCES_TERM_FONT_DIR=$PREFERENCES_TERM/font
PREFERENCES_TERM_TITLE_DIR=$PREFERENCES_TERM/title

# TERM
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$TERM_PROGRAM" == "iTerm"* ]]; then
        source $PREFERENCES_TERM_COLOR_DIR/iterm2.sh
        source $PREFERENCES_TERM_TITLE_DIR/iterm2.sh
    else
        source $PREFERENCES_TERM_COLOR_DIR/xtermcontrol.sh
        source $PREFERENCES_TERM_FONT_DIR/apple_terminal.sh
        source $PREFERENCES_TERM_TITLE_DIR/xtermcontrol.sh
    fi
else
    source $PREFERENCES_TERM_COLOR_DIR/xtermcontrol.sh
    source $PREFERENCES_TERM_TITLE_DIR/xtermcontrol.sh

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

[[ $(type -t setColor) != function ]] && function setColor { :; }
[[ $(type -t setFont) != function ]] && function setFont { :; }
[[ $(type -t setTitle) != function ]] && function setTitle { :; }

export -f setFont
export -f setColor
export -f setTitle

source $PREFERENCES_TERM/wrapper.sh
setTerm default


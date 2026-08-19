#!/usr/bin/env bash

source $PREFERENCES_DIR/util/override.sh
PREFERENCES_TERM="${PREFERENCES_TERM:-$PREFERENCES_DIR/term}"

function loadTermType {
    local colorSet=$1
    local fontSet=$2
    local titleSet=$3

    [ -z $colorSet ] && function setTermColor { :; } || source $PREFERENCES_TERM/color/$colorSet.sh
    [ -z $fontSet ] && function setTermFont { :; } || source $PREFERENCES_TERM/font/$fontSet.sh
    [ -z $titleSet ] && function setTermTitle { :; } || source $PREFERENCES_TERM/title/$titleSet.sh
}

function loadTerms {
    # Don't bother the shell within vim terminal or from ssh
    local ignoring_key=(VIM SSH_TTY)

    for key in "${ignoring_key[@]}"; do
        if [[ ! -z ${!key:+x} ]]; then
            echo "Skip loading term utils because environment variable $key is not null"
            loadTermType '' '' ''
            return
        fi
    done

    case $PREFERENCES_OS in
        'Darwin')
            case $TERM_PROGRAM in
                'iTerm'*)
                    loadTermType 'iterm2' '' 'iterm2'
                    ;;
                'vscode'*)
                    loadTermType 'xtermcontrol' '' ''
                    ;;
                *)
                    if [ -n "$KITTY_PID" ] && [ "$KITTY_PID" -gt 0 ]; then
                        loadTermType '' '' 'xtermcontrol'
                    else
                        loadTermType 'xtermcontrol' 'apple_terminal' 'xtermcontrol'
                    fi
                    ;;
            esac
            ;;
        *)
            # Fast-path environment variable detection (0ms, 0 process forks)
            if [ -n "$KITTY_PID" ] && [ "$KITTY_PID" -gt 0 ] 2>/dev/null; then
                loadTermType '' '' 'xtermcontrol'
            elif [[ "$TERM_PROGRAM" == "vscode"* ]]; then
                loadTermType 'xtermcontrol' '' ''
            elif [ -n "$GNOME_TERMINAL_SCREEN" ] || [ -n "$GNOME_TERMINAL_SERVICE" ]; then
                loadTermType 'xtermcontrol' 'gnome_terminal' 'xtermcontrol'
            elif [ "$TERM_PROGRAM" == "kgx" ] || [ -n "$KGX_PID" ]; then
                loadTermType 'xtermcontrol' '' 'xtermcontrol'
            else
                # Slow-path fallback to process inspection if no env signature is found
                local terminal=""
                if command -v ps &>/dev/null; then
                    terminal=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))" 2>/dev/null)
                fi

                case $terminal in
                    'gnome-terminal'*)
                        loadTermType 'xtermcontrol' 'gnome_terminal' 'xtermcontrol'
                        ;;
                    'kgx') # gnome-console
                        loadTermType 'xtermcontrol' '' 'xtermcontrol'
                        ;;
                    'kitty')
                        loadTermType '' '' 'xtermcontrol'
                        ;;
                    'vscode'*)
                        loadTermType 'xtermcontrol' '' ''
                        ;;
                    *)
                        loadTermType 'xtermcontrol' '' 'xtermcontrol'
                        ;;
                esac
            fi
            ;;
    esac
}

function setTerm {
    local profile=$(echo $1 | sed 's/^profile_\(.*\)/\1/')
    local title=$2

    setTermColor $profile
    setTermFont $profile
    setTermTitle $profile $title
}

function defaultTerm {
    setTerm profile_default
}


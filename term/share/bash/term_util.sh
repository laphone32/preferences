#!/usr/bin/env bash
# File: term/share/bash/term_util.sh

if declare -f sourceShare &>/dev/null; then
    sourceShare bash override.sh 2>/dev/null || true
else
    source "${PREFERENCES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}/bash/share/bash/override.sh" 2>/dev/null || true
fi
source "$PREFERENCES_DIR/term/common.sh" 2>/dev/null || true

# Default no-op definitions
function setTermFont { :; }

# Initialize compiled OSC themes
ensureTermThemesCompiled
[ -f "$PREFERENCES_WORKSPACE_TERM/theme/compiled_osc.sh" ] && source "$PREFERENCES_WORKSPACE_TERM/theme/compiled_osc.sh"

function setTermColor {
    local profile=$1
    local varName="_PREFERENCES_TERM_${profile^^}"
    export _PREFERENCES_TERM_CURRENT="${!varName:-$_PREFERENCES_TERM_DEFAULT}"
    echo -ne "$_PREFERENCES_TERM_CURRENT"
}

function setTermTitle {
    local profile=$1
    local extra=$2
    preferencesSetTitle.py "$profile" "$extra" 2>/dev/null
}

function loadTermFontType {
    local fontSet=$1
    [ -n "$fontSet" ] && [ -f "$PREFERENCES_WORKSPACE_TERM/font/$fontSet.sh" ] && source "$PREFERENCES_WORKSPACE_TERM/font/$fontSet.sh" || function setTermFont { :; }
}

function loadTerms {
    # Don't bother the shell within vim terminal or from ssh
    local ignoring_key=(VIM SSH_TTY)

    for key in "${ignoring_key[@]}"; do
        if [[ ! -z ${!key:+x} ]]; then
            echo "Skip loading term utils because environment variable $key is not null"
            return
        fi
    done

    # Kitty self-manages fonts and colors natively via watcher.py
    if [ -n "$KITTY_PID" ] && [ "$KITTY_PID" -gt 0 ] 2>/dev/null; then
        if [[ "$PS1" != *"\033]0;"* ]]; then
            PS1="\[\033]0;\w\007\]$PS1"
        fi
        return
    fi

    case $PREFERENCES_OS in
        'Darwin')
            case $TERM_PROGRAM in
                'iTerm'*|'vscode'*)
                    loadTermFontType ''
                    ;;
                *)
                    # Apple Terminal
                    loadTermFontType 'apple_terminal'
                    ;;
            esac
            ;;
        'Linux')
            if [ -n "$GNOME_TERMINAL_SCREEN" ] || [ -n "$GNOME_TERMINAL_SERVICE" ]; then
                loadTermFontType 'gnome_terminal'
            else
                loadTermFontType ''
            fi
            ;;
        *)
            loadTermFontType ''
            ;;
    esac

    # Command wrappers for osc managed terminals
    function wrapTermCommand {
        local preAction=$1
        local cmdName=$2
        local preHook="trap defaultTerm RETURN"$'\n'"$preAction"
        wrap "$preHook" '' "$cmdName" '' 'local _ret=$?; defaultTerm; return $_ret'
    }

    wrapTermCommand 'setTerm profile_vim "$*"' vim
    wrapTermCommand 'setTerm profile_vim "$*"' vimdiff

    wrapTermCommand 'setTerm profile_sudo "$*"' sudo
    wrapTermCommand 'setTerm profile_sudo "$*"' su

    local sshAction='
        local confirmed=false
        function setTermAndBreak {
            setTerm $1 $2
            confirmed=true
        }

        for argu in $@
        do
            # For the usage xxx@bind_addr
            arguhost=${argu#*@}
            case $arguhost in
                -*) ;;
                prod.*) setTermAndBreak profile_prod $argu ;;
                uat.*) setTermAndBreak profile_uat $argu ;;
                docker.* | container.*) setTermAndBreak profile_container $argu ;;
                *) setTermAndBreak profile_remote $argu ;;
            esac

            [ $confirmed = true ] && break;
        done'
    wrapTermCommand "$sshAction" ssh

    # Ensure PS1 always emits the default term OSC sequence and directory title on prompt render
    if [[ "$PS1" != *"_PREFERENCES_TERM_DEFAULT"* ]]; then
        PS1="\[\033]0;\w\007\]\[\${_PREFERENCES_TERM_DEFAULT}\]$PS1"
    fi

    defaultTerm
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

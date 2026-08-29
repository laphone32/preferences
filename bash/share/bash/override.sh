#!/usr/bin/env bash
# File: bash/share/bash/override.sh

[[ "${_PREFERENCES_BASH_OVERRIDE_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_BASH_OVERRIDE_SOURCED=yes

function bindCommand {
    local expression=$1
    local prefix=$2
    local name=$3
    local target=$4
    local postfix=$5

    # 1. Matches "command <name>" in existing wrappers (e.g., 'command vim -u ~/.vimrc "$@"')
    #    Places $prefix BEFORE 'command' and $postfix AFTER '<name>' (e.g., 'VIMINIT=... command vim -c ... -u ...')
    local re_command="(.*[[:space:]]|^)(command[[:space:]]+$name)([[:space:]].*|$)"

    # 2. Matches standalone "<name>" as a whole word (e.g., in aliases like 'ls --color=auto')
    #    Replaces '<name>' with $target (e.g., 'command ls --color=auto')
    local re_name="(.*[[:space:]]|^)($name)([[:space:]].*|$)"

    # 3. Matches trailing parameter pack "$@" at the end of a function body (e.g., 'python3 "$@"')
    #    Inserts $prefix and $postfix BEFORE "$@" (e.g., 'python3 -v "$@"')
    local re_params="(.*)([[:space:]]*\"\\\$@\"[[:space:]]*;?[[:space:]]*$)"

    if [[ "$expression" =~ $re_command ]]; then
        echo "${BASH_REMATCH[1]}$prefix command $name $postfix${BASH_REMATCH[3]}"
    elif [[ "$expression" =~ $re_name ]]; then
        echo "${BASH_REMATCH[1]}$prefix $target $postfix${BASH_REMATCH[3]}"
    elif [[ "$expression" =~ $re_params ]]; then
        echo "${BASH_REMATCH[1]} $prefix $postfix ${BASH_REMATCH[2]}"
    else
        echo "$prefix ${expression:-$target} $postfix"
    fi
}

function _wrap {
    local name=$1
    local preHook=$2
    local preCommand=$3
    local command=$4
    local postCommand=$5
    local postHook=$6

    # Automatically prefix with 'command' only when self-wrapping to prevent infinite recursion
    local target="$command"
    if [ "$name" == "$command" ]; then
        target="command $command"
    fi

    local content=''
    local parameterPack='"$@"'

    case $(type -t $name) in
        'alias')
            local origin="${BASH_ALIASES[$name]}"
            unalias $name
            content="$(bindCommand "$origin" "$preCommand" "$name" "$target" "$postCommand") $parameterPack"
            ;;
        'function')
            # Extract existing function body without sed:
            # 1. 'declare -f' retrieves the standardized function definition.
            # 2. '${func_def#*\{}' trims everything up to the opening brace '{'.
            # 3. '${origin%\}}' trims the trailing closing brace '}'.
            local func_def=$(declare -f "$name")
            local origin="${func_def#*\{}"
            origin="${origin%\}}"
            content=$(bindCommand "$origin" "$preCommand" "$name" "$target" "$postCommand")
            unset -f $name
            ;;
        *)
            # Handles 'file', 'builtin', 'keyword', and '' (uninstalled / not yet in PATH).
            # If self-wrapping (wrap), automatically invokes 'command $name' so it is recursion-safe
            # and ready when installed later. If replacing (replace), invokes the target directly.
            content="$preCommand $target $postCommand $parameterPack"
            ;;
    esac

    eval "function $name {
        $preHook
        $content
        $postHook
    }"
}

function wrap {
    local preHook=$1
    local preCommand=$2
    local name=$3
    local postCommand=$4
    local postHook=$5

    _wrap "$name" "$preHook" "$preCommand" "$name" "$postCommand" "$postHook"
}

function replace {
    local name=$1
    local preHook=$2
    local targetCommand=$3
    local postHook=$4

    _wrap "$name" "$preHook" "" "$targetCommand" "" "$postHook"
}

function wrapCommand {
    replace "$1" "$2" "$3" "$4"
}

function wrapPreHook {
    wrap "$1" '' "$2"
}

function wrapParameterBind {
    wrap '' '' "$1" "$2"
}

function wrapPostHook {
    wrap '' '' "$1" '' "$2"
}

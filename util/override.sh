#!/usr/bin/env bash
[[ "${_PREFERENCES_UTIL_OVERRIDE_SOURCED:-""}" == "yes" ]] && return 0
_PREFERENCES_UTIL_OVERRIDE_SOURCED=yes

function bindCommand {
    local expression=$1
    local prefix=$2
    local commandName=$3
    local postfix=$4

    sed "s/\<$commandName\>/${prefix//\//\\\/} ${commandName//\//\\\/} ${postfix//\//\\\/} /g" <<< $expression
}

function wrap {
    local preHook=$1
    local preCommand=$2
    local name=$3
    local postCommand=$4
    local postHook=$5

    local content=''
    local parameterPack='"$@"'

    case $(type -t $name) in
        'alias')
            local origin=$(alias $name | sed "s/^alias $name='\(.*\)'/\1/")
            content="$preCommand $(sed "s/\<$name\>/command $name/g" <<< $origin) $postCommand $parameterPack"
            unalias $name
            ;;
        'function')
            local origin=$(type $name | sed '1,3d;$d')
            content=$(bindCommand "$origin" "$preCommand" "$name" "$postCommand")
            unset -f $name
            ;;
        'keyword' | 'builtin' | 'file')
            content="$preCommand command $name $postCommand $parameterPack"
            ;;
        '')
            content="$preCommand $postCommand $parameterPack"
            ;;
        *)
            content=$(bindCommand "$name" "$preCommand" ${!name} "$postCommand $parameterPack")
            ;;
    esac

    eval "function $name {
        $preHook
        $content
        $postHook
    }"
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


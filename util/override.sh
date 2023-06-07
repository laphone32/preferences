#!/usr/bin/env bash

function wrap {
    local name=$2
    local origin=''
    local parameterPack='$@'

    case $(type -t $name) in
        'alias')
            origin="$(alias $name | sed "s/^alias $name='\(.*\)'/\1/") $parameterPack"
            unalias $name
            ;;
        'function')
            origin=$(type $name | sed '1,3d;$d')
            unset -f $name
            ;;
        'builtin' | 'keyword')
            origin="$name $parameterPack"
            ;;
        '')
            ;;
        *)
            origin="${!name} $parameterPack"
            ;;
    esac

    eval "function $name {
        $1
        $origin
        $3
    }"
}



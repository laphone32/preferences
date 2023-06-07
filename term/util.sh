#!/usr/bin/env bash

function setTerm {
    setTermColor $1
    setTermFont $1
    setTermTitle $1 $2
}

function defaultTerm {
    setTerm default
}

function termAlias {
    eval "function $1 { trap defaultTerm RETURN; ${@:2} \$@; }"
}



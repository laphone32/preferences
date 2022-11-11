#/bin/bash

if [[ $(type -t setColor) != function ]]; then
    function setColor { :; }
    export -f setColor
fi

if [[ $(type -t setFont) != function ]]; then
    function setFont { :; }
    export -f setFont
fi

function setTerm {
    setColor $1
    setFont $1
}

function recover {
    setTerm default
}

trap recover EXIT;


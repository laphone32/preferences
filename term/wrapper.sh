#/bin/bash

function setTerm {
    setColor $1
    setFont $1
}

function recover {
    setTerm default
}

trap recover EXIT;


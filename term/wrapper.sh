#/bin/bash

function setTerm {
    setTermColor $1
    setTermFont $1
    setTermTitle $1
}

function recover {
    setTerm default
}

trap recover EXIT;


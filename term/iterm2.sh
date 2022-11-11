#/bin/bash

function setTerm {
    local profile title

    case $1 in
        "vim" )
            profile="Vim"
            title="[Vim]"
            ;;
        "prod" )
            profile="Prod"
            title="> PROD <"
            ;;
        "uat" )
            profile="UAT"
            title="> UAT <"
            ;;
        "remote" )
            profile="Remote"
            title="> REMOTE <"
            ;;
        "docker" )
            profile="Container"
            title="> Container <"
            ;;
        *)
            profile="Default"
            title="[LOCAL]"
            ;;
    esac
    echo -ne "\033]50;SetProfile=$profile\a"
    echo -ne "\033]0;$title\007"
}

export -f setTerm


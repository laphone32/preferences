#/bin/bash

function setTitle {
    local title

    case $1 in
        "vim" )
            title="[Vim]"
            ;;
        "prod" )
            title="> PROD <"
            ;;
        "uat" )
            title="> UAT <"
            ;;
        "remote" )
            title="> REMOTE <"
            ;;
        "docker" )
            title="> Container <"
            ;;
        *)
            title="[LOCAL]"
            ;;
    esac
    echo -ne "\033]0;$title\007"
}


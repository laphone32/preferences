#/bin/bash

function setColor {
    local profile

    case $1 in
        "vim" )
            profile="Vim"
            ;;
        "prod" )
            profile="Prod"
            ;;
        "uat" )
            profile="UAT"
            ;;
        "remote" )
            profile="Remote"
            ;;
        "container" )
            profile="Container"
            ;;
        *)
            profile="Default"
            ;;
    esac
    echo -ne "\033]50;SetProfile=$profile\a"
}


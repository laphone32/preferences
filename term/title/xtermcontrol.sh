#/bin/bash

function setTitle {
    local background title

    case $1 in
        "vim")
            title="[Vim]"
            ;;
        "prod")
            title="> PROD <"
            ;;
        "uat")
            title="> UAT <"
            ;;
        "remote")
            title="> REMOTE <"
            ;;
        "docker")
            title="> Container <"
            ;;
        *)
            title="[LOCAL]"
            ;;
    esac

    xtermcontrol --title=$title
}


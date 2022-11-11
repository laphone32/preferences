#/bin/bash

function setTerm {
    local fg="white"
    local bg="#555557575353"
    local title="[LOCAL]"

    case $1 in
        "vim" )
            bg="#213440"
            title="[Vim]"
            ;;
        "prod" )
            bg="#691B1B"
            title="> PROD <"
            ;;
        "uat" )
            bg="#245524"
            title="> UAT <"
            ;;
        "remote" )
            bg="#34346565a4a4"
            title="> REMOTE <"
            ;;
        "docker" )
            bg="#0b0a2b"
            title="> Container <"
            ;;
        *)
            bg="#555557575353"
            title="[LOCAL]"
            ;;
    esac

    xtermcontrol --fg=$fg --bg=$bg --title=$title
}

export -f setTerm

#export LAPHONE_DEFAULT_TERM="setTerm white #555557575353 [LOCAL]"
#export LAPHONE_VIM_TERM="setTerm white #213440 [Vim]"
#export LAPHONE_PRODUCTION_TERM="setTerm white #691B1B >PROD<"
#export LAPHONE_UAT_TERM="setTerm white #245524 >UAT<"
#export LAPHONE_REMOTE_TERM="setTerm white #34346565a4a4 >REMOTE<"
#export LAPHONE_DOCKER_TERM="setTerm white #0b0a2b >DOCKER<"


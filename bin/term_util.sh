#/bin/bash

SETTERM=xtermcontrol

function setTerm {
    $SETTERM --fg=$1 --bg=$2 --title=$3
}

export LAPHONE_DEFAULT_TERM="setTerm white #555557575353 [LOCAL]"
export LAPHONE_VIM_TERM="setTerm white #393b39 [Vim]"
export LAPHONE_PRODUCTION_TERM="setTerm white #691B1B >PROD<"
export LAPHONE_UAT_TERM="setTerm white #245524 >UAT<"
export LAPHONE_REMOTE_TERM="setTerm white #34346565a4a4 >REMOTE<"
export LAPHONE_DOCKER_TERM="setTerm white #0b0a2b >DOCKER<"

function recover {
    $LAPHONE_DEFAULT_TERM
}

trap recover EXIT;


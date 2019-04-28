#/bin/bash

SETTERM=xtermcontrol

function setTerm {
    $SETTERM --fg=$1 --bg=$2 --title=$3 
}

export LAPHONE_DEFAULT_TERM="setTerm white #555557575353 [LOCAL]"
export LAPHONE_PRODUCTION_TERM="setTerm white #691B1B >>>PROD<<<"
export LAPHONE_UAT_TERM="setTerm white #245524 >>>UAT<<<"
export LAPHONE_REMOTE_TERM="setTerm white #34346565a4a4 >>>REMOTE<<<"

function recover {
    $LAPHONE_DEFAULT_TERM
}

trap recover EXIT;


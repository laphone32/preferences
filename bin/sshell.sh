#!/bin/bash

HERE="$(dirname "$0")"
. $HERE/term_util.sh

for argu in $@
do
    # For the usage xxx@bind_addr
    arguhost=${argu#*@}

    ( [[ $arguhost =~ ^- ]] ) || # Skip the ssh arguments
    ( [[ $arguhost =~ ^prod. ]] && $LAPHONE_PRODUCTION_TERM ) || # Production env. connection
    ( [[ $arguhost =~ ^uat. ]] && $LAPHONE_UAT_TERM ) || # Testing env. connection
    ( [[ $arguhost =~ ^local. ]] && $LAPHONE_LOCAL_TERM ) || # localhost env. connection
    $LAPHONE_REMOTE_TERM
done

ssh $@


#!/bin/bash

. term_util.sh

function recover {
    $LAPHONE_DEFAULT_TERM
}

trap recover EXIT;


for argu in $@
do
    # For the usage xxx@bind_addr
    arguhost=${argu#*@}

    ( [[ $arguhost =~ ^- ]] ) || # Skip the ssh arguments
    ( [[ $arguhost =~ ^prod. ]] && $LAPHONE_PRODUCTION_TERM ) || # Production env. connection
    ( [[ $arguhost =~ ^uat. ]] && $LAPHONE_UAT_TERM ) || # Testing env. connection
    $LAPHONE_REMOTE_TERM
done

ssh $@


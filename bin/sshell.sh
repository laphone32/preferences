#!/bin/bash

. term_util.sh

for argu in $@
do
    # For the usage xxx@bind_addr
    arguhost=${argu#*@}

    ( [[ $arguhost =~ ^- ]] ) || # Skip the ssh arguments
    ( [[ $arguhost =~ ^prod. ]] && $LAPHONE_PRODUCTION_TERM ) || # Production env. connection
    ( [[ $arguhost =~ ^test. ]] && $LAPHONE_REMOTE_TERM ) || # Testing env. connection
    $LAPHONE_REMOTE_TERM
done

ssh $@; $LAPHONE_DEFAULT_TERM


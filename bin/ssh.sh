#!/bin/bash

source $PREFERENCES_TERM/wrapper.sh

for argu in $@
do
    # For the usage xxx@bind_addr
    arguhost=${argu#*@}

    ( [[ $arguhost =~ ^- ]] ) || # Skip the ssh arguments
    ( [[ $arguhost =~ ^prod. ]] && setTerm prod ) || # Production env. connection
    ( [[ $arguhost =~ ^uat. ]] && setTerm uat ) || # Testing env. connection
    ( [[ $arguhost =~ ^docker. ]] && setTerm docker ) || # localhost env. connection
    setTerm remote
done

ssh $@


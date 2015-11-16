#!/bin/bash

for argu in $@
do
    # For the usage xxx@bind_addr
    arguhost=${argu#*@}

    ( [[ $arguhost =~ ^- ]] ) || # Skip the ssh arguments
    ( [[ $arguhost =~ ^prod. ]] && setcolor.sh Prod) || # Production env. connection
    ( [[ $arguhost =~ ^test. ]] && setcolor.sh Test) || # Testing env. connection
    setcolor.sh Remote
done

ssh $@; setcolor.sh Normal


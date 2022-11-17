#!/bin/bash

source $PREFERENCES_TERM/util.sh

function _vim {
    setTerm vim
    command vim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/vimrc $@
}

function _vimdiff {
    setTerm vim
    command vimdiff --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/vimrc $@
}

function _ssh {
    for argu in $@
    do
        # For the usage xxx@bind_addr
        arguhost=${argu#*@}

        ( [[ $arguhost =~ ^- ]] ) || # Skip the ssh arguments
        ( [[ $arguhost =~ ^prod. ]] && setTerm prod ) || # Production env. connection
        ( [[ $arguhost =~ ^uat. ]] && setTerm uat ) || # Testing env. connection
        ( [[ $arguhost =~ ^docker. ]] && setTerm container ) || # localhost env. connection
        setTerm remote
    done

    command ssh $@
}

termAlias vim _vim
termAlias vimdiff _vimdiff
termAlias ssh _ssh

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='gls --color=auto'
fi

alias grep='grep --color=auto'
alias gvim='gvim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/gvimrc'
alias python='python3'
alias sbt='SBT_OPTS="-Xms512M -Xmx8G -Xss2M -XX:MaxMetaspaceSize=1024M" sbt'



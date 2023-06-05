#!/bin/bash

source $PREFERENCES_DIR/term/util.sh

function _vim {
    setTerm vim
    command vim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/vimrc $@
}

function _vimdiff {
    setTerm vim
    command vimdiff --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/vimrc $@
}

function _ssh {
    local confirmed=false
    function setTermAndBreak {
        setTerm $1 $2
        confirmed=true
    }

    for argu in $@
    do
        # For the usage xxx@bind_addr
        arguhost=${argu#*@}

        case $arguhost in
            -*) ;;
            prod.*) setTermAndBreak prod $argu ;;
            uat.*) setTermAndBreak uat $argu ;;
            docker.* | container.*) setTermAndBreak container $argu ;;
            *) setTermAndBreak remote $argu ;;
        esac

        [ $confirmed = true ] && break;
    done

    command ssh $@
}

termAlias vim _vim
termAlias vimdiff _vimdiff
termAlias ssh _ssh


alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias gvim='gvim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/vim/gvimrc'
alias python='python3'
alias sbt='SBT_OPTS="-Xms512M -Xmx8G -Xss2M -XX:MaxMetaspaceSize=1024M" sbt'



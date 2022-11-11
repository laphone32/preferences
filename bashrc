
export PREFERENCES_BIN=$PREFERENCES_DIR/bin
export PREFERENCES_TERM=$PREFERENCES_DIR/term

# TERM
if [[ "$OSTYPE" == "darwin"* ]]; then
    source $PREFERENCES_TERM/iterm2.sh
else
    source $PREFERENCES_TERM/xtermcontrol.sh
fi
setTerm default

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1

export PS1='\[\033[0;32m\]\u\[\e[0m\]:\w\[\033[0;33m\]$(__git_ps1)\[\e[0m\]# '

export PATH=$HOME/bin:$PATH:$PREFERENCES_BIN

export GIT_EDITOR=vim
export EDITOR=vim

export LC_MESSAGES=C
export GTEST_COLOR=1

declare -x LS_COLORS="no=00:fi=00:di=01;36:ln=02;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:"

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='gls --color'
fi

alias vim='$PREFERENCES_BIN/vim.sh'
alias vimdiff='$PREFERENCES_BIN/vimdiff.sh'
alias gvim='gvim --cmd "lang en_US.UTF-8" -u $PREFERENCES_DIR/gvimrc'
alias ssh='$PREFERENCES_BIN/ssh.sh'
alias python='python3'
alias sbt='SBT_OPTS="-Xms512M -Xmx8G -Xss2M -XX:MaxMetaspaceSize=1024M" sbt'

# ripgrep
#if type rg &> /dev/null; then
#    export FZF_DEFAULT_COMMAND='rg --files --hidden'
#fi



PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREFERENCES_BIN=$PREFERENCES_DIR/bin
PS1="\[\033[0;32m\]\u\[\e[0m\]:\w\\[\033[0;33m\]$(__git_ps1)\[\e[0m\]\$ "

export PATH=$PATH:$PREFERENCES_BIN

export GIT_EDITOR=vim
setcolor.sh Normal

declare -x LS_COLORS="no=00:fi=00:di=01;36:ln=02;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:"

alias vim='vim --cmd "lang en_US.utf8" -u $PREFERENCES_DIR/vimrc'
alias gvim='gvim --cmd "lang en_US.utf8" -u $PREFERENCES_DIR/vimrc'
alias ssh='$PREFERENCES_BIN/sshell.sh'
alias python='python3'


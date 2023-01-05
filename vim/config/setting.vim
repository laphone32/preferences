" For Delphi
let g:pascal_delphi = 1

set encoding=utf-8
" English
language mes en_US.UTF-8
set langmenu=en_US.UTF-8

syntax on
set hidden
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
set autochdir

set nobackup
set smartindent
set autoindent
set nocursorline
set fileformats=unix,dos

if g:os == 'Linux'
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

set ruler
set hlsearch
set ignorecase
set smartcase
set incsearch

set laststatus=2
set backspace=indent,eol,start

" No beep
set noeb vb t_vb=

" Folding
"set foldmarker={,}
"set foldmethod=marker
set foldmethod=syntax
set foldlevel=0 " Close in default
set foldnestmax=15

" Using 256 colors
set t_Co=256
"colorscheme desert
colorscheme nord
if (has('termguicolors'))
    set termguicolors
endif

" For chinese
set ambiwidth=double

" Don't give |ins-completion-menu| messages.
set shortmess+=c

" set shell
set shell=bash

" Let plugin handle the mode
set noshowmode

set updatetime=300

" views
set viewoptions-=options

" For Vundle
set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
Plugin 'tpope/vim-fugitive'
Plugin 'L9'
Plugin 'Raimondi/delimitMate'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'Valloric/YouCompleteMe'
Plugin 'itchyny/lightline.vim'
Plugin 'airblade/vim-rooter'
Plugin 'scrooloose/syntastic'
Plugin 'AndrewRadev/linediff.vim'
Plugin 'JalaiAmitahl/maven-compiler.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" For Delphi
let pascal_delphi = 1

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
set clipboard=unnamedplus

set ruler
set hlsearch
set incsearch

set laststatus=2
set backspace=indent,eol,start

" Folding
set foldmarker={,}
"set foldmethod=marker
set foldmethod=syntax
set foldlevel=0 " Close in default
set foldnestmax=15

colorscheme desert

" Set GUI fonts
"set guifont=Monaco\ 18
set guifont=Hermit\ bold\ 18
"set guifont=Monaco:h16
"set guifont=Droid\ Sans\ Mono\ 20
"set guifont=Source_Code_Pro:h14
" Without toolbar
set guioptions-=T
" Without gui tabbar, always use modified text tabbar
set guioptions-=e
" Without menubar
set guioptions-=m
" Without auto select/copy
set guioptions-=a
set guioptions-=A
set guioptions-=aA
" Disable scrolls
set guioptions-=r
set guioptions-=L
" Disable all cursor blinking
"set guicursor+=a:blinkon0
" Startup in full screen size
"au GUIEnter * simalt ~x
if has("gui_running")
    " GUI is running or is about to start.
    " Maximize gvim window.
    set lines=99 columns=999
endif

" Using 256 colors
set t_Co=256

" For chinese
set ambiwidth=double

" To know the filetype of *.pc
filetype plugin on
autocmd BufRead,BufEnter *.pc set filetype=esqlc

" Start in the line last read
if has("autocmd")
	autocmd BufRead *.txt set tw=1024
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line ("'\"") <= line("$") |
		\   exe "normal g'\"" |
		\ endif
endif

" Key-mappings for changing tabs
map <A-q> :tabnew 
imap <A-q> <ESC>:tabnew 
map <A-1> 1gt
imap <A-1> <ESC>1gt
map <A-2> 2gt
imap <A-2> <ESC>2gt
map <A-3> 3gt
imap <A-3> <ESC>3gt
map <A-4> 4gt
imap <A-4> <ESC>4gt
map <A-5> 5gt
imap <A-5> <ESC>5gt
map <A-6> 6gt
imap <A-6> <ESC>6gt
map <A-7> 7gt
imap <A-7> <ESC>7gt
map <A-8> 8gt
imap <A-8> <ESC>8gt
map <A-9> 9gt
imap <A-9> <ESC>9gt
map <A-Right> :tabn<CR>
imap <A-Right> <ESC>:tabn<CR>
map <A-Left> :tabp<CR>
imap <A-Left> <ESC>:tabp<CR>
map <A-l> :tabn<CR>
imap <A-l> <ESC>:tabn<CR>
map <A-h> :tabp<CR>
imap <A-h> <ESC>:tabp<CR>
" map <C-n> :call NERDTreeToggleAndFind() <CR>
map <C-n> :NERDTreeToggle<CR>
map <C-b> :CtrlPBuffer<CR>

map <F8> :vertical diffsplit 
map <F9> :set cursorline!<CR>
map <F10> :set cursorcolumn!<CR>

" Do not cover the register for the content operated by `dd' and `x'
noremap dd "9dd
noremap x "9x

"""""""""""""""""""""""""""""""""""" CtrlP
set wildignore+=*.swp,*.class,*.so

"""""""""""""""""""""""""""""""""""" YouCompleteMe
let g:ycm_filetype_whitelist = {'c' : 1, 'h' : 1, 'cpp' : 1, 'hpp' : 1, 'java' : 1, 'python' : 1, 'sh' : 1, 'pom' : 1}
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 1
let g:ycm_always_populate_location_list = 1

" Semantic trigger
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ }


" remove annoying preview window appearing on top of vim
let g:ycm_add_preview_to_completeopt = 0
set completeopt-=preview

" Color
highlight Pmenu ctermfg=0 ctermbg=242 guifg=black guibg=gray45
highlight PmenuSel ctermfg=242 ctermbg=8 guifg=gray45 guibg=black

"""""""""""""""""""""""""""""""""""" NERDTree
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }
set shell=bash

" returns true iff is NERDTree open/active
function! IsNTOpen()        
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" calls NERDTreeFind iff NERDTree is active, current window contains a modifiable file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNTOpen() && strlen(expand('%')) > 0 && !&diff
    let l:curwinnr = winnr()
    NERDTreeFind
    exec l:curwinnr . "wincmd w"
"    wincmd p
  endif
endfunction

" Open NERDTree in the directory of the current file (or /home if no file is open)
function! NERDTreeToggleAndFind()
  " If NERDTree is open in the current buffer
  if IsNTOpen()
    exe ":NERDTreeClose"
  else
    exe ":NERDTreeFind"
  endif
endfunction

autocmd BufEnter * call SyncTree()

"""""""""""""""""""""""""""""""""""""" lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightLineFugitive',
      \   'filename': 'LightLineFilename',
      \   'fileformat': 'LightLineFileformat',
      \   'filetype': 'LightLineFiletype',
      \   'fileencoding': 'LightLineFileencoding',
      \   'mode': 'LightLineMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }

function! LightLineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ''  " edit here for cool mark
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

" vim-rooter
let g:rooter_silent_chdir = 1

" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Eclim
let g:EclimJavaSearchSingleResult = 'edit'
let g:EclimJavaCallHierarchyDefaultAction = 'edit'
let g:EclimMakeLCD = 1
let g:EclimCompletionMethod = 'omnifunc'


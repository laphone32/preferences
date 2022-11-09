
set nocompatible

"""""""""""""""""""""""""""""""""""" Vim Plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'tpope/vim-fugitive'
Plug 'Raimondi/delimitMate'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-rooter'
Plug 'AndrewRadev/linediff.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'arcticicestudio/nord-vim'
call plug#end()

" Detect OS - Linux | Windows | Darwin
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" For Delphi
let pascal_delphi = 1

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

if g:os == "Linux"
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

" For chinese
set ambiwidth=double

" Don't give |ins-completion-menu| messages.
set shortmess+=c

" FileTypes
filetype plugin on
augroup fileTypeGroup
  autocmd! 
  " *.pc as esql
  autocmd BufRead,BufEnter *.pc set filetype=esqlc
  " *.sbt as scala
  autocmd BufRead,BufNewFile *.sbt set filetype=scala
augroup end

" Start in the line last read
if has("autocmd")
    augroup lastReadGroup
      autocmd!
      autocmd BufRead *.txt set tw=1024
      autocmd BufReadPost *
          \ if line("'\"") > 0 && line ("'\"") <= line("$") |
          \   exe "normal g'\"" |
          \ endif
    augroup end
endif

" Remove the tailling white spaces automatically on every save without altering search history and cursor
function! <SID>StripTaillingWhiteSpaces()
    if !&binary && &filetype != 'diff'
        let pos = getpos(".")
        keeppatterns %s/\s\+$//e
        call cursor(pos)
    endif
endfunction
augroup removeTaillingWhiteSpaceGroup
    autocmd!
    autocmd FileType c,cpp,java,scala,sbt,python,perl,bash,sh,groovy autocmd BufWritePre <buffer> :call <SID>StripTaillingWhiteSpaces()
augroup end

" Key-mappings for tab switching
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

map <F8> :vertical diffsplit 
map <F9> :set cursorline!<CR>
map <F10> :set cursorcolumn!<CR>

map <A-F12> :terminal<CR>

let mapleader = '\'

" Do not cover the register for the content operated by `dd' and `x'
noremap dd "9dd
noremap x "9x

"""""""""""""""""""""""""""""""""""" Coc
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gc <Plug>(coc-declaration)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)

" Use gh for show documentation in preview window
nnoremap <silent> gh :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('gh', 'in')
  endif
endfunction

" Remap for doing codeAction of current line
nmap <silent>ac <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <silent>af <Plug>(coc-fix-current)
" Rename current symbol/word
nmap <silent>ar <Plug>(coc-rename)
" Codelens
nmap <silent>al <Plug>(coc-codelens-action)


nmap <silent> <leader>p :CocList files<CR>
vmap <silent> <leader>p :<C-u>call <SID>GrepFromSelected('files')<CR>

nmap <silent> <leader>b :CocList buffers<CR>
vmap <silent> <leader>b :<C-u>call <SID>GrepFromSelected('buffers')<CR>

nmap <silent> <leader>f :CocList grep<CR>
vmap <silent> <leader>f :<C-u>call <SID>GrepFromSelected('grep')<CR>

nmap <silent> <leader>s :CocList symbols<CR>
vmap <silent> <leader>s :<C-u>call <SID>GrepFromSelected('symbols')<CR>

nmap <silent> <leader>d :CocList diagnostics<CR>
nmap <silent> <leader><leader> :CocListResume<CR>

function! s:GrepFromSelected(dst)
  let saved_unnamed_register = @@
  normal! `<v`>y
  let word = escape(substitute(@@, '\n$', '', 'g'), '| ')
  let @@ = saved_unnamed_register
  execute 'CocList --input='.word.' '.a:dst
endfunction

" use enter to confirm the completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

if has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

augroup cocGroup
  autocmd!
  autocmd FileType json syntax match Comment +\/\/.\+$+
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  " Hightlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

set updatetime=300

let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-cmake',
    \ 'coc-css',
    \ 'coc-docker',
    \ 'coc-go',
    \ 'coc-groovy',
    \ 'coc-json',
    \ 'coc-java',
    \ 'coc-lists',
    \ 'coc-markdownlint',
    \ 'coc-metals',
    \ 'coc-python',
    \ 'coc-sh',
    \ 'coc-sql',
    \ 'coc-thrift-syntax-support',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-yaml',
    \]

let g:coc_user_config = {
    \ 'suggest': {
        \ 'noselect': v:false,
        \ 'enablePreview': v:true,
    \ },
    \
    \ 'diagnostic': {
        \ 'refreshOnInsertMode': v:true,
        \ 'errorSign': '>>',
        \ 'warningSign': '!!',
        \ 'infoSign': '->',
        \ 'hintSign': '**',
    \ },
    \
    \ 'list.source.files.excludePatterns': ['**/.bloop/*'],
    \
    \ 'clangd': {
        \ 'arguments': ['--background-index'],
    \ },
    \
    \ 'metals': {
        \ 'sbtScript': 'sbt',
        \ 'statusBarEnabled': v:true,
    \ },
    \
    \ 'go': {
        \ 'goplsOptions': {
            \ 'usePlaceholders': v:true,
            \ 'completeUnimported': v:true,
        \ }
    \ },
    \
    \ 'python': {
        \ 'jediEnabled': v:false,
    \ }
  \ }

" Color
"highlight Pmenu ctermfg=0 ctermbg=242 guifg=black guibg=gray45
"highlight PmenuSel ctermfg=234 ctermbg=38 guifg=gray45 guibg=LightBlue

"""""""""""""""""""""""""""""""""""" NERDTree
let g:NERDTreeGitStatusIndicatorMapCustom = {
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

" Auto quit when choosing file to open
let NERDTreeQuitOnOpen=1
" Let statusline handle the status line
let g:NERDTreeStatusline = -1
" Sync the tree root and vim root
let NERDTreeChDirMode=2


nmap <silent> <leader>n :NERDTreeToggle<CR>

" returns true iff is NERDTree open/active
function! s:isNTOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" calls NERDTreeFind iff NERDTree is active, current window contains a modifiable file, and we're not in vimdiff
function! s:syncTree()
  if &modifiable && s:isNTOpen() && strlen(expand('%')) > 0 && !&diff && bufname('%') !~# 'NERD_tree'
    NERDTreeFind
    wincmd p
  endif
endfunction

augroup nerdTreeGroup
  autocmd!
  autocmd BufEnter * call s:syncTree()
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup end

"""""""""""""""""""""""""""""""""""""" lightline
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename' ], [ 'cocstatus' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'filename' ] ],
      \   'right': [ [ 'lineinfo' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'LightLineGitBranch',
      \   'filename': 'LightLineFilename',
      \   'fileformat': 'LightLineFileformat',
      \   'filetype': 'LightLineFiletype',
      \   'fileencoding': 'LightLineFileencoding',
      \   'mode': 'LightLineMode',
      \   'lineinfo': 'LightLineLineInfo',
      \   'cocstatus': 'coc#status'
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }
      
" Let lightline show the mode
set noshowmode

function! LightLineModified()
  return &modified ? ' +' : &modifiable ? '' : ' -'
endfunction

function! LightLineReadonly()
  return &readonly ? '= ' : ''
endfunction

function! FileIsNormal()
  return &filetype !~ 'qf\|help\|list\|nerdtree\|vim-plug'
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return !FileIsNormal() ? '' :
        \ LightLineReadonly() .
        \ ('' != fname ? fname : '[No Name]') .
        \ LightLineModified()
endfunction

function! WinWidthIsEnough(...)
  let length = a:0 > 0 ? a:1 : 70
  return winwidth(0) > length
endfunction

function! LightLineGitBranch()
  if FileIsNormal() && WinWidthIsEnough()
    let mark = ''  " edit here for cool mark
    let branch = FugitiveHead()
    return strlen(branch) ? mark.branch : ''
  else
    return ''
  endif
endfunction

function! LightLineFileformat()
  return WinWidthIsEnough() ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return WinWidthIsEnough() ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return WinWidthIsEnough() ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return !FileIsNormal() ? expand('%:t') : 
        \ WinWidthIsEnough(60) ? lightline#mode() : ''
endfunction

function! LightLineLineInfo()
  return !FileIsNormal() ? '' : printf("%3d:%-2d", line('.'), col('.'))
endfunction

augroup lightlineGroup
  autocmd!
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
  autocmd BufRead call lightline#update()
augroup end

"""""""""""""""""""""""""""""""""""""" vim-rooter
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['.gitmodules', '.git/', 'build.sbt', 'CMakeLists.txt']
let g:rooter_resolve_links = 1

"""""""""""""""""""""""""""""""""""""" vim-nord
let g:nord_uniform_diff_background = 1



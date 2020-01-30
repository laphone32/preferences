
set nocompatible
"""""""""""""""""""""""""""""""""""" Vim Plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/L9'
Plug 'Raimondi/delimitMate'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'Valloric/YouCompleteMe', {'do' : 'python3 install.py --clangd-completer'}
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-rooter'
Plug 'AndrewRadev/linediff.vim'
Plug 'JalaiAmitahl/maven-compiler.vim'
Plug 'docker/docker' , {'rtp' : '/contrib/syntax/vim/', 'for' : 'dockerfile'}
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'derekwyatt/vim-scala'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
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
set incsearch

set laststatus=2
set backspace=indent,eol,start

" No beep
set noeb vb t_vb=

" Folding
set foldmarker={,}
"set foldmethod=marker
set foldmethod=syntax
set foldlevel=0 " Close in default
set foldnestmax=15

" Using 256 colors
set t_Co=256
colorscheme desert

" Set GUI fonts
if g:os == 'Linux'
    " Monaco / Hermit / Droid Sans Mono / Source Code Pro 
    set guifont=Hermit\ bold\ 20
else
    set guifont=Hermit:h20
endif

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
" au GUIEnter * simalt ~x
if has("gui_running")
    " GUI is running or is about to start.
    " Maximize gvim window.
    set lines=99 columns=999
endif


" For chinese
set ambiwidth=double

" Don't give |ins-completion-menu| messages.
set shortmess+=c

" To know the filetype of *.pc
filetype plugin on
augroup esqlGroup
  autocmd! 
  autocmd BufRead,BufEnter *.pc set filetype=esqlc
augroup end

" Treat *.sbt as scala
augroup scalaGroup
  autocmd!
  au BufRead,BufNewFile *.sbt set filetype=scala
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
    autocmd FileType c,cpp,java,scala,sbt,python,perl,bash,sh autocmd BufWritePre <buffer> :call <SID>StripTaillingWhiteSpaces()
augroup end

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

map <F8> :vertical diffsplit 
map <F9> :set cursorline!<CR>
map <F10> :set cursorcolumn!<CR>

map <A-F12> :terminal<CR>

" Do not cover the register for the content operated by `dd' and `x'
noremap dd "9dd
noremap x "9x

"""""""""""""""""""""""""""""""""""" FZF
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
let g:fzf_history_dir = '~/.local/share/fzf-history'

command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
map <C-p><C-p> :Files<CR>
map <C-p><C-b> :Buffer<CR>
map <C-p><C-f> :Rg<CR>

"""""""""""""""""""""""""""""""""""" YouCompleteMe
"let g:ycm_filetype_whitelist = {'c' : 1, 'h' : 1, 'cpp' : 1, 'hpp' : 1, 'java' : 1, 'python' : 1, 'sh' : 1, 'pom' : 1, 'scala' : 1}
"let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_confirm_extra_conf = 1
"let g:ycm_always_populate_location_list = 1
"" Let clangd fully control code completion
"let g:ycm_clangd_uses_ycmd_caching = 0
"" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
"let g:ycm_clangd_binary_path = exepath("clangd")
"let g:ycm_clangd_args = ['-background-index']
"
"" Semantic trigger
"let g:ycm_semantic_triggers =  {
"            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
"            \ 'cs,lua,javascript': ['re!\w{2}'],
"            \ }
"
"let g:ycm_language_server = [
"            \ { 'name': 'scala',
"            \   'filetypes': [ 'scala' ],
"            \   'cmdline': [ 'metals-vim' ],
"            \   'project_root_files': [ 'build.sbt' ]
"            \ }
"            \ ]
"
"
"" remove annoying preview window appearing on top of vim
"let g:ycm_add_preview_to_completeopt = 0
"" set completeopt-=preview
"" nmap <silent> gd :YcmCompleter GoToDeclaration<CR>
"" nmap <silent> gy <Plug>(coc-type-definition)
"" nmap <silent> gi :YcmCompleter GoToImplementation<CR>
"" nmap <silent> gr :YcmCompleter GoToReferences<CR>
 
"""""""""""""""""""""""""""""""""""" Coc
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gc <Plug>(coc-declaration)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <silent> dl :CocList diagnostics<CR>

" Use gh for show documentation in preview window
nnoremap <silent> gh :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for do codeAction of current line
nmap <silent>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <silent>af  <Plug>(coc-fix-current)
" Rename current symbol/word
nmap <silent>ar  <Plug>(coc-rename)


" use enter to confirm the completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

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
    \ 'coc-json',
    \ 'coc-java',
    \ 'coc-vimlsp',
    \ 'coc-metals',
    \]

" Color
highlight Pmenu ctermfg=0 ctermbg=242 guifg=black guibg=gray45
highlight PmenuSel ctermfg=234 ctermbg=245 guifg=gray45 guibg=black

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

" Auto quit when choosing file to open
let NERDTreeQuitOnOpen=1
" Let statusline handle the status line
let g:NERDTreeStatusline = -1
" Sync the tree root and vim root
let NERDTreeChDirMode=2


map <C-n> :NERDTreeToggle<CR>

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
      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename' ] ],
      \   'right': [ [ 'hinter_error', 'hinter_warning', 'hinter_hint', 'hinter_info' ], [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'LightLineGitBranch',
      \   'filename': 'LightLineFilename',
      \   'fileformat': 'LightLineFileformat',
      \   'filetype': 'LightLineFiletype',
      \   'fileencoding': 'LightLineFileencoding',
      \   'mode': 'LightLineMode',
      \ },
      \ 'component_expand': {
      \   'hinter_error': 'LightLineCocError',
      \   'hinter_warning': 'LightLineCocWarning',
      \   'hinter_hint': 'LightLineCocHint',
      \   'hinter_info': 'LightLineCocInfo',
      \ },
      \ 'component_type': {
      \   'hinter_error': 'error',
      \   'hinter_warning': 'warning',
      \   'hinter_hint': 'tabsel',
      \   'hinter_info': 'middle',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }
      
" Let lightline show the mode
set noshowmode

function! LightLineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help' && &readonly ? '=' : ''
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return &filetype ==# 'qf' ? '' :
        \ fname =~ 'location\|NERD_tree' ? '' :
        \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction
  
function! LightLineGitBranch()
  try
    if expand('%:t') !~? 'location\|NERD' && exists('*fugitive#head')
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
  return &filetype ==# 'qf' ? 'QuickFix' :
        \ fname == 'location' ? 'Locations' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! s:LightLineCocDiagnostic(kind) abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) || get(info, a:kind, 0) == 0
    return ''
  endif
  return '•' . info[a:kind]
endfunction

function! LightLineCocError() abort
  return s:LightLineCocDiagnostic('error')
endfunction

function! LightLineCocWarning() abort
  return s:LightLineCocDiagnostic('warning')
endfunction

function! LightLineCocInfo() abort
  return s:LightLineCocDiagnostic('information')
endfunction

function! LightLineCocHint() abort
  return s:LightLineCocDiagnostic('hint')
endfunction

augroup lightlineGroup
  autocmd!
  autocmd User CocDiagnosticChange call lightline#update()
augroup end

" vim-rooter
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['.gitmodules', '.git/', 'build.sbt', 'CMakeLists.txt']
let g:rooter_resolve_links = 1

" Eclim
"let g:EclimJavaSearchSingleResult = 'edit'
"let g:EclimJavaCallHierarchyDefaultAction = 'edit'
"let g:EclimMakeLCD = 1
"let g:EclimCompletionMethod = 'omnifunc'

" vim-scala
let g:scala_scaladoc_indent = 1


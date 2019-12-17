
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
  autocmd FileType json syntax match Comment +\/\/.\+$+
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

"    map <C-n> :call NERDTreeToggleAndFind() <CR>
map <C-n> :NERDTreeToggle<CR>

map <C-p> :FZF<CR>
map <C-b> :Buffer<CR>
map <C-f> :Rg<CR>

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

augroup fzfGroup
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup end


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
 
"""""""""""""""""""""""""""""""""""" Metals
command! -nargs=0 MetalsImport :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-import' })
command! -nargs=0 MetalsDoctor :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'doctor-run' })
command! -nargs=0 MetalsConnect :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-connect' })

"""""""""""""""""""""""""""""""""""" Coc
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> dl :CocList diagnostics<CR>

" Use man for show documentation in preview window
nnoremap <silent> gh :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" use enter to confirm the completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Close the preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

augroup cocGroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

set updatetime=300

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

augroup nerdTreeGroup
  autocmd!
  autocmd BufEnter * call SyncTree()
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup end

" Let statusline handle the status line
let g:NERDTreeStatusline = -1

"""""""""""""""""""""""""""""""""""""" lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename', 'cocerror' ] ],
      \   'right': [ [ 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'LightLineGitBranch',
      \   'filename': 'LightLineFilename',
      \   'fileformat': 'LightLineFileformat',
      \   'filetype': 'LightLineFiletype',
      \   'fileencoding': 'LightLineFileencoding',
      \   'mode': 'LightLineMode',
      \   'cocerror': 'LightLineCocError',
      \ },
      \ 'component_type': {
      \ 'cocerror': 'error',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }
      
" Let lightline show the mode
set noshowmode

function! LightLineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return fname =~ 'location\|NERD_tree' ? '' :
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
  return fname == 'location' ? 'Locations' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! LightLineCocError()
  let s:error_sign = '❌ '
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info)
    return ''
  endif
  let errmsgs = []
  if get(info, 'error', 0)
    call add(errmsgs, s:error_sign . info['error'])
  endif
  return trim(join(errmsgs, ' ') . ' ' . get(g:, 'coc_status', ''))
endfunction

augroup lightlineGroup
  autocmd!
  autocmd User CocDiagnosticChange call lightline#update()
augroup end

" vim-rooter
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['.gitmodules', '.git/']
let g:rooter_resolve_links = 1

" Eclim
let g:EclimJavaSearchSingleResult = 'edit'
let g:EclimJavaCallHierarchyDefaultAction = 'edit'
let g:EclimMakeLCD = 1
let g:EclimCompletionMethod = 'omnifunc'

" vim-scala
let g:scala_scaladoc_indent = 1



set nocompatible
"""""""""""""""""""""""""""""""""""" Vim Plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
    if empty(glob(data_dir . '/autoload/plug.vim'))
        silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif



function s:afterPlugLoad(plugName) abort
    call LoadConfig('plugin_setting/' .. a:plugName .. '.config.vim')
endfunction

let s:plug = {'toLoad': [], 'toHold': []}
function s:plugAdd(repo, ...) abort
    let plugName = split(a:repo, '/')[1]
    let s:property = (a:0 == 1) ? a:1 : {}

    if has_key(s:property, 'on') || has_key(s:property, 'for')
        call add(s:plug.toHold, plugName)
    else
        let s:property.on = []
        call add(s:plug.toLoad, plugName)
    endif

    execute 'Plug ' .. string(a:repo) .. ', ' .. string(s:property)
endfunction

function s:plugBegin(plugPath) abort
    execute 'call plug#begin(' .. string(a:plugPath) .. ')'

    command! -nargs=+ -bar PlugAdd call s:plugAdd(<args>)
endfunction

function s:installAutocmd() abort
    execute 'augroup PlugLoadGroup'
    execute 'autocmd!'

    for plugName in s:plug.toHold
        execute 'autocmd User ' .. plugName .. ' call s:afterPlugLoad(' .. string(plugName) .. ')'
    endfor

    execute 'augroup end'
endfunction

function s:plugEnd() abort
    call s:installAutocmd()

    execute 'call plug#end()'

    for plug in s:plug.toLoad
        call s:plugLoad(plug)
    endfor
endfunction

function s:plugLoad(plugName) abort
    call plug#load(a:plugName)
    call s:afterPlugLoad(a:plugName)
endfunction

call s:plugBegin('~/.vim/bundle')
PlugAdd 'tpope/vim-fugitive'
PlugAdd 'Raimondi/delimitMate'
PlugAdd 'preservim/nerdtree', {'on': '<Plug>(file-manager-call)'}
PlugAdd 'Xuyuanp/nerdtree-git-plugin', {'on': '<Plug>(file-manager-call)'}
PlugAdd 'itchyny/lightline.vim'
PlugAdd 'airblade/vim-rooter'
PlugAdd 'AndrewRadev/linediff.vim', {'on': 'Linediff'}
PlugAdd 'neoclide/coc.nvim', {'branch': 'release'}
PlugAdd 'nordtheme/vim'
""PlugAdd 'arcticicestudio/nord-vim'
PlugAdd 'ap/vim-css-color'
""PlugAdd 'junegunn/fzf', { 'do': { -> fzf#install() }}
""PlugAdd 'junegunn/fzf.vim'
call s:plugEnd()


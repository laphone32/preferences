vim9script

set nocompatible

# Vim Plug
var data_dir = has('nvim') ? stdpath('data') .. '/site' : '~/.vim'
if empty(glob(data_dir .. '/autoload/plug.vim'))
    silent execute '!curl -fLo ' .. data_dir .. '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

def g:AfterPlugLoad(confName: string)
    g:LoadConfig('plugin_setting/' .. confName .. '.config.vim')
enddef

def RepoToPlug(repo: string): list<string>
    return [split(repo, '/')[1], substitute(repo, '/', '-', '')]
enddef

var plug = {toLoad: [], toHold: []}

def g:PlugAdd(repo: string, property_arg = {})
    var property = property_arg
    if has_key(property, 'on') || has_key(property, 'for')
        add(plug.toHold, repo)
    else
        property.on = []
        add(plug.toLoad, repo)
    endif

    execute 'Plug ' .. string(repo) .. ', ' .. string(property)
enddef

def PlugBegin(plugPath: string)
    plug#begin(plugPath)
    command! -nargs=+ -bar PlugAdd call g:PlugAdd(<args>)
enddef

def InstallAutocmd()
    augroup PlugLoadGroup
        autocmd!
        for repo in plug.toHold
            var val = RepoToPlug(repo)
            var plugName = val[0]
            var confName = val[1]
            execute 'autocmd User ' .. plugName .. ' call g:AfterPlugLoad(' .. string(confName) .. ')'
        endfor
    augroup END
enddef

def PlugLoad(repo: string)
    var val = RepoToPlug(repo)
    var plugName = val[0]
    var confName = val[1]
    plug#load(plugName)
    g:AfterPlugLoad(confName)
enddef

def PlugEnd()
    InstallAutocmd()
    plug#end()
    for repo in plug.toLoad
        PlugLoad(repo)
    endfor
enddef

# Load all plugins
PlugBegin('~/.vim/bundle')
PlugAdd 'tpope/vim-fugitive'
PlugAdd 'Raimondi/delimitMate'
# PlugAdd 'preservim/nerdtree', {on: '<Plug>(file-manager-call)'}
# PlugAdd 'Xuyuanp/nerdtree-git-plugin', {on: '<Plug>(file-manager-call)'}
PlugAdd 'itchyny/lightline.vim'
PlugAdd 'airblade/vim-rooter'
PlugAdd 'AndrewRadev/linediff.vim', {on: 'Linediff'}
# PlugAdd 'neoclide/coc.nvim', {branch: 'release'}
PlugAdd 'prabirshrestha/vim-lsp'
PlugAdd 'mattn/vim-lsp-settings'
PlugAdd 'prabirshrestha/asyncomplete.vim'
PlugAdd 'prabirshrestha/asyncomplete-lsp.vim'
PlugAdd 'nordtheme/vim'
# PlugAdd 'arcticicestudio/nord-vim'
PlugAdd 'ap/vim-css-color'
# PlugAdd 'junegunn/fzf', { 'do': { -> fzf#install() }}
# PlugAdd 'junegunn/fzf.vim'
PlugEnd()

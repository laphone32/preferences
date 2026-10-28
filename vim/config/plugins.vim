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

def RepoToPlug(repo: string, property: dict<any> = {}): list<string>
    var custom_as = get(property, 'as', '')
    if repo =~# '^[.~/]'
        var clean = substitute(repo, '/\+$', '', '')
        var name = !empty(custom_as) ? custom_as : fnamemodify(clean, ':t')
        return [name, '_local-' .. name]
    endif

    var parts = split(repo, '/')
    var plugName = !empty(custom_as) ? custom_as : parts[1]
    var confName = parts[0] .. '-' .. parts[1]
    return [plugName, confName]
enddef

var plug: dict<list<list<string>>> = {toLoad: [], toHold: []}

def g:PlugAdd(repo_arg: string, property_arg = {})
    var repo = repo_arg
    var property = property_arg
    var [plugName, confName] = RepoToPlug(repo, property)

    if repo =~# '^\.'
        repo = resolve(g:vimrcDir .. '/' .. repo)
    endif

    if has_key(property, 'on') || has_key(property, 'for')
        add(plug.toHold, [plugName, confName])
    else
        add(plug.toLoad, [plugName, confName])
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
        for [plugName, confName] in plug.toHold
            execute 'autocmd User ' .. plugName .. ' call g:AfterPlugLoad(' .. string(confName) .. ')'
        endfor
    augroup END
enddef

def PlugEnd()
    InstallAutocmd()
    plug#end()
    for [_, confName] in plug.toLoad
        g:AfterPlugLoad(confName)
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

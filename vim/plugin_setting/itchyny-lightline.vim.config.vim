vim9script

# lightline
g:lightline = {
    colorscheme: 'nord',
    active: {
        left: [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename' ], [ 'lspStatus' ] ],
        right: [ [ 'lineinfo' ], [ 'fileformat', 'fileencoding', 'filetype' ] ]
    },
    inactive: {
        left: [ [ 'filename' ] ],
        right: [ [ 'lineinfo' ] ]
    },
    component_function: {
        gitbranch: 'LightLineGitBranch',
        filename: 'LightLineFilename',
        fileformat: 'LightLineFileformat',
        filetype: 'LightLineFiletype',
        fileencoding: 'LightLineFileencoding',
        mode: 'LightLineMode',
        lineinfo: 'LightLineLineInfo',
        lspStatus: 'LspStatus'
    },
    subseparator: { left: '|', right: '|' }
}

def g:LightLineModified(): string
    return &modified ? ' +' : &modifiable ? '' : ' -'
enddef

def g:LightLineReadonly(): string
    return &readonly ? '= ' : ''
enddef

def g:FileIsNormal(): bool
    return &filetype !~ 'qf\|help\|list\|nerdtree\|vim-plug'
enddef

def g:LightLineFilename(): string
    var fname = expand('%:t')
    if !g:FileIsNormal()
        return ''
    endif
    return g:LightLineReadonly() .. (fname != '' ? fname : '[No Name]') .. g:LightLineModified()
enddef

def g:WinWidthIsEnough(length = 70): bool
    return winwidth(0) > length
enddef

def g:LightLineGitBranch(): string
    if g:FileIsNormal() && g:WinWidthIsEnough()
        var mark = ''  # edit here for cool mark
        var branch = g:GitBranchName()
        return strlen(branch) > 0 ? mark .. branch : ''
    else
        return ''
    endif
enddef

def g:LightLineFileformat(): string
    return g:WinWidthIsEnough() ? &fileformat : ''
enddef

def g:LightLineFiletype(): string
    return g:WinWidthIsEnough() ? (&filetype != '' ? &filetype : 'no ft') : ''
enddef

def g:LightLineFileencoding(): string
    return g:WinWidthIsEnough() ? (&fenc != '' ? &fenc : &enc) : ''
enddef

def g:LightLineMode(): string
    if !g:FileIsNormal()
        return expand('%:t')
    elseif g:WinWidthIsEnough(60)
        return lightline#mode()
    else
        return ''
    endif
enddef

def g:LightLineLineInfo(): string
    return !g:FileIsNormal() ? '' : printf("%3d:%-2d", line('.'), col('.'))
enddef

augroup lightlineGroup
    autocmd!
    autocmd User LspStatusChange call lightline#update()
    autocmd BufRead call lightline#update()
augroup END

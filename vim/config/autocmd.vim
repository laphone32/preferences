vim9script

filetype plugin on

# FileTypes
augroup fileTypeGroup
    autocmd!
    # *.pc as esql
    autocmd BufRead,BufEnter *.pc set filetype=esqlc
    # *.sbt as scala
    autocmd BufRead,BufNewFile *.sbt set filetype=scala
    # bashrc as sh
    autocmd BufRead,BufNewFile bashrc set filetype=bash
augroup END

# Start in the line last read
augroup lastReadGroup
    autocmd!
    autocmd BufWinLeave,BufLeave,BufWritePost,BufHidden,QuitPre ?* ++nested silent! mkview!
    autocmd BufWinEnter ?* silent! loadview
augroup END

# Remove the trailing white spaces automatically on every save without altering search history and cursor
def StripTrailingWhiteSpaces()
    if !&binary && &filetype != 'diff'
        var pos = getpos('.')
        keeppatterns :%s/\s\+$//e
        cursor(pos[1], pos[2])
    endif
enddef

augroup removeTrailingWhiteSpaceGroup
    autocmd!
    autocmd FileType c,cpp,java,scala,sbt,python,perl,bash,sh,groovy,vim autocmd BufWritePre <buffer> StripTrailingWhiteSpaces()
augroup END

# Auto adjust the split
augroup resizeGroup
    autocmd!
    autocmd VimResized * wincmd =
augroup END

# Diff always wrap
augroup diffGroup
    autocmd!
    autocmd VimEnter * if &diff | windo set wrap | endif
augroup END

# Dynamic terminal title bridge
def UpdateTerminalTitle()
    # 1. Ignore popups, floating windows, preview, and non-normal/unlisted buffers
    if win_gettype() != '' || !&buflisted || &buftype != ''
        return
    endif

    var fullpath = expand('%:p')
    var fName = expand('%')

    # 2. Empty buffer on startup (e.g. starting Vim without arguments)
    if empty(fName)
        system('preferencesSetTitle.py vim')
        return
    endif

    # 3. Any real file existing on disk is unconditionally accepted
    if filereadable(fullpath)
        system('preferencesSetTitle.py vim ' .. shellescape(expand('%:~:.')))
        return
    endif

    # 4. New unsaved files (accepts standard paths, rejects pseudo-schemes & scratch buffers containing ':' or '!')
    if fName !~ '[:!]'
        system('preferencesSetTitle.py vim ' .. shellescape(expand('%:~:.')))
    endif
enddef

augroup terminalTitleGroup
    autocmd!
    autocmd VimEnter,BufEnter,BufFilePost,BufWritePost,DirChanged * UpdateTerminalTitle()
augroup END

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

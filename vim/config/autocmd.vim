
filetype plugin on

if has('autocmd')

    " FileTypes
    augroup fileTypeGroup
      autocmd!
      " *.pc as esql
      autocmd BufRead,BufEnter *.pc set filetype=esqlc
      " *.sbt as scala
      autocmd BufRead,BufNewFile *.sbt set filetype=scala
    augroup end


    " Start in the line last read
    augroup lastReadGroup
      autocmd!
      autocmd BufWinLeave,BufLeave,BufWritePost,BufHidden,QuitPre ?* nested silent! mkview!
      autocmd BufWinEnter ?* silent! loadview
    augroup end


    " Remove the tailling white spaces automatically on every save without altering search history and cursor
    function! s:stripTaillingWhiteSpaces()
        if !&binary && &filetype != 'diff'
            keeppatterns %s/\s\+$//e
            call cursor(getpos('.'))
        endif
    endfunction
    augroup removeTaillingWhiteSpaceGroup
        autocmd!
        autocmd FileType c,cpp,java,scala,sbt,python,perl,bash,sh,groovy,vim autocmd BufWritePre <buffer> :call s:stripTaillingWhiteSpaces()
    augroup end


    " Auto adjust the split
    augroup resizeGroup
        autocmd!
        autocmd VimResized * wincmd =
    augroup end

endif



    
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
      autocmd BufRead *.txt set tw=1024
      autocmd BufReadPost *
          \ if line("'\"") > 0 && line ("'\"") <= line("$") |
          \   exe "normal g'\"" |
          \ endif
    augroup end

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

endif



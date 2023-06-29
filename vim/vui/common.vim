
function! BufferAllocate(name) abort
    let l:currentBufferNr = bufnr('%')
    let l:ret = bufnr(a:name, 1)

    exec 'b ' . l:ret
    setlocal noswapfile nobuflisted bufhidden=hide buftype=nofile
    exec 'b ' . l:currentBufferNr

    return l:ret
endfunction

function! BufferClear(id) abort
    let l:currentBufferNr = bufnr('%')
    execute 'b ' . a:id
    silent! normal! gg"_dG'
    exec 'b ' . l:currentBufferNr
endfunction


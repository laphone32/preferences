
function! FromSelected(command)
  let l:saved_unnamed_register = @@
  normal! `<v`>y
  let l:word = escape(substitute(@@, '\n$', '', 'g'), '| ')
  let @@ = l:saved_unnamed_register
  execute substitute(a:command, '%s', '''' .. l:word .. '''', 'g')
endfunction

function AddListKeyMappings(call, normal_command, virtual_command)
    execute 'nnoremap <Plug>(normal-' .. a:call .. ') :' .. a:normal_command .. '<cr>'
    execute "vnoremap <Plug>(virtual-" .. a:call .. ") :<C-u>call FromSelected(\'" .. a:virtual_command .. "\')<cr>"
endfunction

function! BufferAllocate(name) abort
    let l:currentBufferNr = bufnr('%')
    let l:ret = bufnr(a:name, 1)

    execute 'buffer ' .. l:ret
    setlocal noswapfile nobuflisted bufhidden=hide buftype=nofile
    execute 'buffer ' .. l:currentBufferNr

    return l:ret
endfunction

function! BufferClear(id) abort
    let l:currentBufferNr = bufnr('%')
    execute 'buffer ' .. a:id
    silent! normal! gg"_dG'
    execute 'buffer ' .. l:currentBufferNr
endfunction


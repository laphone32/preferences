
function! FromSelected(command)
  let l:saved_unnamed_register = @@
  normal! `<v`>y
  let l:word = escape(substitute(@@, '\n$', '', 'g'), '| ')
  let @@ = l:saved_unnamed_register
  let l:final_command = substitute(a:command, '%s', 'l:word', 'g')
  echo a:final_command
  execute a:final_command
endfunction

function AddListKeyMappings(call, normal_command, virtual_command)
    echo 'nnoremap <Plug>(normal-'.a:call.') :'.a:normal_command.'<cr>'
    execute 'nnoremap <Plug>(normal-'.a:call.') :'.a:normal_command.'<cr>'

    echo "vnoremap <Plug>(virtual-".a:call.") :<C-u>call FromSelected(\'".a:virtual_command."\')<cr>"
    execute "vnoremap <Plug>(virtual-".a:call.") :<C-u>call FromSelected(\'".a:virtual_command."\')<cr>"
endfunction



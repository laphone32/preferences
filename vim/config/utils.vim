
function! FromSelected(command)
  let l:saved_unnamed_register = @@
  normal! `<v`>y
  let l:word = escape(substitute(@@, '\n$', '', 'g'), '| ')
  let @@ = l:saved_unnamed_register
  execute substitute(a:command, '%s', ''''.l:word.'''', 'g')
endfunction

function AddListKeyMappings(call, normal_command, virtual_command)
    execute 'nnoremap <Plug>(normal-'.a:call.') :'.a:normal_command.'<cr>'
    execute "vnoremap <Plug>(virtual-".a:call.") :<C-u>call FromSelected(\'".a:virtual_command."\')<cr>"
endfunction


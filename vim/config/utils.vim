vim9script

def g:FromSelected(command: string)
    var saved_unnamed_register = @@
    normal! `<v`>y
    var word = escape(substitute(@@, '\n$', '', 'g'), '| ')
    @@ = saved_unnamed_register
    execute substitute(command, '%s', word, 'g')
enddef

def g:AddListKeyMappings(call_name: string, normal_command: string, virtual_command: string)
    execute 'nnoremap <Plug>(normal-' .. call_name .. ') :' .. normal_command .. '<cr>'
    execute 'vnoremap <Plug>(virtual-' .. call_name .. ") :<C-u>call FromSelected('" .. virtual_command .. "')<cr>"
enddef

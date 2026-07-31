vim9script

def g:FromSelected(command: string)
    var saved_unnamed_register = getreg('"')
    var saved_unnamed_type = getregtype('"')
    normal! gvy
    var word = getreg('"')
    word = substitute(word, '\n$', '', '')
    word = substitute(word, '\n', ' ', 'g')
    var word_escaped = escape(word, '\|&~')
    setreg('"', saved_unnamed_register, saved_unnamed_type)
    execute substitute(command, '%s', word_escaped, 'g')
enddef

def g:AddListKeyMappings(call_name: string, normal_command: string, virtual_command: string)
    execute 'nnoremap <Plug>(normal-' .. call_name .. ') :' .. normal_command .. '<cr>'
    execute 'vnoremap <Plug>(virtual-' .. call_name .. ") :<C-u>call FromSelected('" .. virtual_command .. "')<cr>"
enddef


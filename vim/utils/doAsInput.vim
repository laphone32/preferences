
let s:doAsInputs = []

function! DoAsInputInit(properties) abort
    let l:context = #{
        \ buffer: '',
        \ id: 0,
        \ onType: {key, all -> return },
        \ legalInput: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '/', '.', '>', '<', '|', '$']
    \ }

    let l:context.id = popup_dialog(l:context.buffer, s:set(a:properties, l:context, #{
        \ minheight: 1,
        \ maxheight: 1,
        \ filter: function('s:onFilter', [l:context]),
        \ hidden: v:true,
    \ }))

    let l:id = len(s:doAsInputs)
    call add(s:doAsInputs, l:context)

    return l:id
endfunction

function! DoAsInputOpen(id, properties = {}) abort
    if a:id < len(s:doAsInputs)
        let l:context = s:doAsInputs[a:id]
        let l:context.buffer = ''
        call popup_settext(l:context.id, l:context.buffer)
        call popup_setoptions(l:context.id, s:set(a:properties, l:context))
        call popup_show(l:context.id)
    endif
endfunction

function! DoAsInputResume(id) abort
    if a:id < len(s:doAsInputs)
        call popup_show(s:doAsInputs[a:id].id)
    endif
endfunction

function! s:set(properties, context, opt = {}) abort
    for [l:key, l:Value] in items(a:properties)
        if l:key == 'onType'
            let a:context.onType = l:Value
        elseif l:key == 'legalInput'
            let a:context.legalInput = l:Value
        elseif l:key == 'width'
            let a:opt.maxwidth = l:Value
            let a:opt.minwidth = l:Value
        elseif l:key == 'buffer'
            let a:context.buffer = l:Value
            call popup_settext(a:context.id, a:context.buffer)
        else
            let a:opt[l:key] = l:Value
        endif
    endfor

    return a:opt
endfunction

function! s:onFilter(context, id, key) abort
    if index(a:context.legalInput, tolower(a:key)) != -1
        let a:context.buffer .= a:key
    elseif a:key is# "\<bs>"
        if len(a:context.buffer) > 1
            let a:context.buffer = a:context.buffer[:len(a:context.buffer) - 2]
        else
            let a:context.buffer = ''
        endif
    elseif a:key is# "\<cr>" || a:key is# "\<esc>"
        call popup_hide(a:id)
    else
    endif

    call popup_settext(a:id, a:context.buffer)
    call function(a:context.onType)(a:key, a:context.buffer)

    return v:true
endfunction


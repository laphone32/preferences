
function! s:onType(key, all)
endfunction

let s:context = #{
    \ buffer: 0,
    \ popup: #{
        \ id: 0,
    \ },
    \ onType: 's:onType',
    \ legalInput: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '/', '.', '>', '<']
\ }

function! DoAsInputInit(properties)
    let s:context.buffer = BufferAllocate('_doAsInputBuffer')
    let s:context.popup.id = popup_dialog(s:context.buffer, s:set(a:properties, #{
            \ minheight: 1,
            \ maxheight: 1,
            \ filter: 's:onFilter',
            \ hidden: v:true,
    \ }))
endfunction

function! DoAsInputOpen(properties)
    call BufferClear(s:context.buffer)

    call popup_setoptions(s:context.popup.id, s:set(a:properties, #{}))
    call popup_show(s:context.popup.id)
endfunction

function! DoAsInputResume()
    call popup_show(s:context.popup.id)
endfunction

function! s:set(properties, opt)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onType'
            let s:context.onType = l:value
        elseif l:key == 'legalInput'
            let s:context.legalInput = l:value
        else
            let a:opt[l:key] = l:value
        endif
    endfor

    return a:opt
endfunction

function! s:onFilter(id, key)
    let l:tmp = getbufline(s:context.buffer, 1)[0]
    if index(s:context.legalInput, tolower(a:key)) != -1
        let l:tmp = l:tmp . a:key
    elseif a:key is# "\<bs>"
        let l:tmp = l:tmp[:len(l:tmp) - 2]
    elseif a:key is# "\<cr>" || a:key is# "\<esc>"
        call popup_hide(a:id)
    else
    endif

    call setbufline(s:context.buffer, 1, l:tmp)
    call function(s:context.onType)(a:key, l:tmp)

    return v:true
endfunction


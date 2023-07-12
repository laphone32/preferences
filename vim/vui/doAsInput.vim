
function! s:onType(key, all)
endfunction

let s:doAsInputProperties = #{
    \ buffer: 0,
    \ popup: #{
        \ id: 0,
        \ opt: #{
            \ minheight: 1,
            \ maxheight: 1,
            \ filter: 's:onFilter',
        \ },
    \ },
    \ onType: 's:onType',
    \ legalInput: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '/', '.', '>', '<']
\ }

function! DoAsInputInit(properties)
    let s:doAsInputProperties.buffer = BufferAllocate('_doAsInputBuffer')

    call s:set(a:properties)
endfunction

function! DoAsInputOpen(properties)
    call BufferClear(s:doAsInputProperties.buffer)

    if s:doAsInputProperties.popup.id != 0
        call popup_close(s:doAsInputProperties.popup.id)
        let s:doAsInputProperties.popup.id = 0
    endif

    call s:set(a:properties)
    let s:doAsInputProperties.popup.id = popup_dialog(s:doAsInputProperties.buffer, s:doAsInputProperties.popup.opt)
    call popup_show(s:doAsInputProperties.popup.id)
endfunction

function! DoAsInputResume()
    call popup_show(s:doAsInputProperties.popup.id)
endfunction

function! s:set(properties)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onType'
            let s:doAsInputProperties.onType = l:value
        elseif l:key == 'legalInput'
            let s:doAsInputProperties.legalInput = l:value
        else
            let s:doAsInputProperties.popup.opt[l:key] = l:value
        endif
    endfor
endfunction

function! s:onFilter(id, key)
    let l:tmp = getbufline(s:doAsInputProperties.buffer, 1)[0]
    if index(s:doAsInputProperties.legalInput, tolower(a:key)) != -1
        let l:tmp = l:tmp . a:key
    elseif a:key is# "\<bs>"
        let l:tmp = l:tmp[:len(l:tmp) - 2]
    elseif a:key is# "\<cr>" || a:key is# "\<esc>"
        call popup_hide(a:id)
    else
    endif

    call setbufline(s:doAsInputProperties.buffer, 1, l:tmp)
    call function(s:doAsInputProperties.onType)(a:key, l:tmp)

    return v:true
endfunction


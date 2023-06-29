
source common.vim

function! s:onType(key)
endfunction

let s:doAsInputProperties = #{
    \ buffer: #{
        \ name: 'doAsInputBuffer',
        \ nr: 0
    \ },
    \ popupOpt: #{
        \ callback: 's:onEnter',
        \ minheight: 1,
        \ maxheight: 1,
        \ filter: 's:onFilter',
    \ },
    \ onType: function('s:onType'),
    \ legalInput: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '/', '.', '>', '<']
\ }

function! DoAsInputInit(properties)
    let s:doAsInputProperties.buffer.nr = BufferAllocate(s:doAsInputProperties.buffer.name)

    call s:set(a:properties)
endfunction

function! s:showWindow()
    call popup_dialog(s:doAsInputProperties.buffer.nr, s:doAsInputProperties.popupOpt)
endfunction

function! DoAsInputOpen(properties)
    call BufferClear(s:doAsInputProperties.buffer.nr)

    call s:set(a:properties)
    call s:showWindow()
endfunction

function! DoAsInputResume()
    call s:showWindow()
endfunction

function! s:set(properties)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onType'
            let s:doAsInputProperties.onType = function(l:value)
        elseif l:key == 'legalInput'
            let s:doAsInputProperties.legalInput = l:value
        else
            let s:doAsInputProperties.popupOpt[l:key] = l:value
        endif
    endfor
endfunction

function! s:onFilter(id, key)
    if index(s:doAsInputProperties.legalInput, tolower(a:key)) != -1
        let l:tmp = getbufline(s:doAsInputProperties.buffer.nr, 1)[0] . a:key
        call setbufline(s:doAsInputProperties.buffer.nr, 1, l:tmp)

        call s:doAsInputProperties.onType(a:key, l:tmp)
    else
        call popup_filter_menu(a:id, a:key)
    endif

    return v:true
endfunction

function! s:onEnter(id, result)
endfunction


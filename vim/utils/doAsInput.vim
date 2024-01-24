
let s:doAsInputs = []

function! DoAsInputInit(properties) abort
    let l:context = #{
        \ buffer: get(a:properties, 'buffer', ''),
        \ id: 0,
        \ onType: get(a:properties, 'onType', {key, all ->  v:null }),
    \ }

    call s:set(a:properties, #{
                \ minheight: 1,
                \ maxheight: 1,
                \ filter: function('s:onFilter', [l:context]),
                \ hidden: v:true,
                \ })

    let l:context.id = popup_dialog(l:context.buffer, a:properties)

    let l:id = len(s:doAsInputs)
    call add(s:doAsInputs, l:context)

    return l:id
endfunction

function! DoAsInputOpen(id, properties = {}) abort
    if a:id < len(s:doAsInputs)
        let l:context = s:doAsInputs[a:id]
        let l:context.buffer = get(a:properties, 'buffer', '')
        let l:context.onType = get(a:properties, 'onType', l:context.onType)
        call s:set(a:properties)

        call popup_setoptions(l:context.id, a:properties)
        call popup_settext(l:context.id, l:context.buffer)
        call popup_show(l:context.id)
    endif
endfunction

function! DoAsInputResume(id) abort
    if a:id < len(s:doAsInputs)
        call popup_show(s:doAsInputs[a:id].id)
    endif
endfunction

function! s:set(properties, opt = {}) abort
    if has_key(a:properties, 'width')
        let l:width = a:properties.width
        let a:properties.maxwidth = l:width
        let a:properties.minwidth = l:width
    endif

    call extend(a:properties, a:opt)
endfunction

function! s:onFilter(context, id, key) abort
    let l:nr = char2nr(a:key)

    if l:nr >= 32 && l:nr <= 126
        let a:context.buffer ..= a:key
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


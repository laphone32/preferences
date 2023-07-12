
function! s:onKey(key, result)
endfunction

function! s:onFilter(popup, id, key)
    let l:line = line('$', a:popup.id) - 1
    let l:height = a:popup.height
    let l:index = a:popup.index

    if a:key is# "\<up>" || a:key is# "\<down>"
        if a:key is# "\<up>"
            let l:index = max([1, l:index - 1])
        elseif a:key is# "\<down>"
            let l:index = min([l:line, l:index + 1])
        endif
        call popup_filter_menu(a:id, a:key)
    else
        if a:key is# "\<pageup>"
            let l:index = max([1, l:index - l:height])
            call popup_setoptions(a:id, #{firstline: l:height * (l:index / l:height) + 1})
        elseif a:key is# "\<pagedown>"
            let l:index = min([l:index + l:height, l:line])
            call popup_setoptions(a:id, #{firstline: l:height * (l:index / l:height) + 1})
        elseif a:key is# "\<home>"
            let l:index = 1
            call popup_setoptions(a:id, #{firstline: l:index})
        elseif a:key is# "\<end>" || a:key is# 'G'
            let l:index = l:line
            call popup_setoptions(a:id, #{firstline: l:index})
        elseif a:key is# "\<esc>" || a:key is# 'q'
            call popup_hide(a:id)
        else
            if a:key is# "\<cr>"
                call popup_hide(a:id)
            endif

            call function(a:popup.onKey)(a:key, l:index)
        endif
    endif

    let a:popup.index = l:index
    return v:true
endfunction


let s:properties = #{
    \ buffer: 0,
    \ popup: #{
        \ id: -1,
        \ index: 1,
        \ height: 10,
        \ onKey: 's:onKey',
        \ opt: #{
            \ firstline: 1,
            \ filter: 's:onFilter',
            \ hidden: v:true,
          \ },
    \ },
  \ }

function! ListMenuInit(properties)
    let s:properties.buffer = BufferAllocate('_listMenuBuffer')

    call s:set(a:properties)
    let s:properties.popup.opt.filter = function('s:onFilter', [s:properties.popup])
    let s:properties.popup.id = popup_menu(s:properties.buffer, s:properties.popup.opt)
endfunction

function! ListMenuBuffer()
    return s:properties.buffer
endfunction

function! s:set(properties)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onKey'
            let s:properties.popup.onKey = l:value
        elseif l:key == 'height'
            let s:properties.popup.height = l:value
            let s:properties.popup.opt.maxheight = l:value
            let s:properties.popup.opt.minheight = l:value
        elseif l:key == 'width'
            let s:properties.popup.opt.maxwidth = l:value
            let s:properties.popup.opt.minwidth = l:value
        else
            let s:properties.popup.opt[l:key]  = l:value
        endif
    endfor
endfunction

function! ListMenuOpen(properties) abort
    call s:set(a:properties)

    call BufferClear(s:properties.buffer)
    let s:properties.popup.index = 1
    let s:properties.popup.opt.firstline = 1
    call popup_setoptions(s:properties.popup.id, s:properties.popup.opt)
    call popup_show(s:properties.popup.id)
endfunction

function! ListMenuResume() abort
    call popup_show(s:properties.popup.id)
endfunction


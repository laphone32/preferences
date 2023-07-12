
function! s:onKey(key, result)
endfunction

function! s:onFilter(popup, id, key)
    let l:line = line('$', a:popup.id) - 1
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
            let l:index = max([1, l:index - a:popup.height])
            call popup_setoptions(a:id, #{firstline: a:popup.height * (l:index / a:popup.height) + 1})
        elseif a:key is# "\<pagedown>"
            let l:index = min([l:index + a:popup.height, l:line])
            call popup_setoptions(a:id, #{firstline: a:popup.height * (l:index / a:popup.height) + 1})
        elseif a:key is# "\<home>"
            let l:index = 1
            call popup_setoptions(a:id, #{firstline: l:index})
        elseif a:key is# "\<end>"
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


let s:listMenuProperties = #{
    \ buffer: 0,
    \ popup: #{
        \ id: -1,
        \ index: 1,
        \ offset: 0,
        \ height: 10,
        \ onKey: 's:onKey',
        \ opt: #{
            \ pos: 'center',
            \ firstline: 1,
            \ filter: 's:onFilter',
          \ },
    \ },
  \ }

function! ListMenuInit(properties)
    let s:listMenuProperties.buffer = BufferAllocate('_listMenuBuffer')

    call s:set(a:properties)
endfunction

function! ListMenuBuffer()
    return s:listMenuProperties.buffer
endfunction

function! s:set(properties)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onKey'
            let s:listMenuProperties.popup.onKey = l:value
        elseif l:key == 'height'
            let s:listMenuProperties.popup.height = l:value
            let s:listMenuProperties.popup.opt.maxheight = l:value
            let s:listMenuProperties.popup.opt.minheight = l:value
        elseif l:key == 'width'
            let s:listMenuProperties.popup.opt.maxwidth = l:value
            let s:listMenuProperties.popup.opt.minwidth = l:value
        else
            let s:listMenuProperties.popup.opt[l:key]  = l:value
        endif
    endfor
endfunction

function! ListMenuOpen(properties) abort
    call s:set(a:properties)

    if s:listMenuProperties.popup.id != -1
        call popup_close(s:listMenuProperties.popup.id)
        let s:listMenuProperties.popup.id = -1
    endif

    call BufferClear(s:listMenuProperties.buffer)
    let s:listMenuProperties.popup.index = 1
    let s:listMenuProperties.popup.offset = 0
    let s:listMenuProperties.popup.opt.firstline = 1
    let s:listMenuProperties.popup.opt.filter = function('s:onFilter', [s:listMenuProperties.popup])
    let s:listMenuProperties.popup.id = popup_menu(s:listMenuProperties.buffer, s:listMenuProperties.popup.opt)
    call popup_show(s:listMenuProperties.popup.id)
endfunction

function! ListMenuResume() abort
    call popup_show(s:listMenuProperties.popup.id)
endfunction


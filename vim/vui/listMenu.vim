
function! s:onKey(key, result)
endfunction

function! s:onFilter(popup, id, key)
    let l:line = line('$', a:popup.id) - 1
    let [l:height, l:index] = [a:popup.height, a:popup.index]
    let [l:cursorRepeat, l:cursorMove] = [0, '']
    let l:opt = {}

    if a:key is# "\<up>"
        let l:index = max([1, l:index - 1])
        let [l:cursorRepeat, l:cursorMove] = [1, "\<up>"]
    elseif a:key is# "\<down>"
        let l:index = min([l:line, l:index + 1])
        let [l:cursorRepeat, l:cursorMove] = [1, "\<down>"]
    elseif a:key is# "\<pageup>"
        let l:firstline = l:height * (l:index / l:height) + 1
        if l:firstline == 1
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<up>"]
            let l:index = l:firstline
        else
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<down>"]
            let l:index = max([1, l:index - l:height])
            let l:opt.firstline = l:height * (l:index / l:height) + 1
        endif
    elseif a:key is# "\<pagedown>"
        let l:firstline = l:height * (l:index / l:height) + 1
        if l:line - l:firstline < l:height
            let [l:cursorRepeat, l:cursorMove] = [l:line - l:index, "\<down>"]
            let l:index = l:line
        else
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<down>"]
            let l:index = min([l:index + l:height, l:line])
            let l:opt.firstline = l:height * (l:index / l:height) + 1
        endif
    elseif a:key is# "\<home>"
        let l:index = 1
        let l:opt.firstline = l:index
    elseif a:key is# "\<end>" || a:key is# 'G'
        let l:index = l:line
        let l:opt.firstline = l:index
    elseif a:key is# "\<esc>" || a:key is# 'q'
        call popup_hide(a:id)
    else
        if a:key is# "\<cr>"
            call popup_hide(a:id)
        endif

        call function(a:popup.onKey)(a:key, l:index)
    endif

""     echo 'index=' . l:index . ' firstline=' . get(l:opt, 'firstline', '') . ' downCursorline=' . l:cursorDown . ' height=' . l:height

    " move page
    if len(l:opt) > 0
        call popup_setoptions(a:id, l:opt)
    endif

    " move cursor
    while l:cursorRepeat > 0
        let l:cursorRepeat = l:cursorRepeat - 1
        call popup_filter_menu(a:id, l:cursorMove)
    endwhile

    let a:popup.index = l:index
    return v:true
endfunction


let s:context = #{
    \ buffer: 0,
    \ popup: #{
        \ id: -1,
        \ index: 1,
        \ height: 10,
        \ onKey: 's:onKey',
    \ },
  \ }

function! ListMenuInit(properties)
    let s:context.buffer = BufferAllocate('_listMenuBuffer')

    let s:context.popup.id = popup_menu(s:context.buffer, s:set(a:properties, #{
                \ filter: function('s:onFilter', [s:context.popup]),
                \ hidden: v:true,
                \ }))
endfunction

function! ListMenuBuffer()
    return s:context.buffer
endfunction

function! s:set(properties, opt)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onKey'
            let s:context.popup.onKey = l:value
        elseif l:key == 'height'
            let s:context.popup.height = l:value
            let a:opt.maxheight = l:value
            let a:opt.minheight = l:value
        elseif l:key == 'width'
            let a:opt.maxwidth = l:value
            let a:opt.minwidth = l:value
        else
            let a:opt[l:key]  = l:value
        endif
    endfor

    return a:opt
endfunction

function! ListMenuOpen(properties) abort
    call BufferClear(s:context.buffer)
    let s:context.popup.index = 1
    call popup_setoptions(s:context.popup.id, s:set(a:properties, #{firstline: 1}))
    call popup_show(s:context.popup.id)
endfunction

function! ListMenuResume() abort
    call popup_show(s:context.popup.id)
endfunction


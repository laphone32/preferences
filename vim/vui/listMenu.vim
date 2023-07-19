
function! s:onKey(key, result) abort
endfunction

function! s:onFilter(context, id, key) abort
    let l:line = line('$', a:context.id) - 1
    let [l:height, l:index] = [a:context.height, a:context.index]
    let [l:cursorRepeat, l:cursorMove] = [0, '']
    let l:opt = {}

    if a:key is# "\<up>"
        let l:index = max([1, l:index - 1])
        let [l:cursorRepeat, l:cursorMove] = [1, "\<up>"]
    elseif a:key is# "\<down>"
        let l:index = min([l:line, l:index + 1])
        let [l:cursorRepeat, l:cursorMove] = [1, "\<down>"]
    elseif a:key is# "\<pageup>" || a:key is# "\<c-b>"
        let l:firstline = l:height * (l:index / l:height) + 1
        if l:firstline == 1
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<up>"]
            let l:index = l:firstline
        else
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<down>"]
            let l:index = max([1, l:index - l:height])
            let l:opt.firstline = l:height * (l:index / l:height) + 1
        endif
    elseif a:key is# "\<pagedown>" || a:key is# "\<c-f>"
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

        call function(a:context.onKey)(a:key, l:index)
    endif

""     echo 'index=' . l:index . ' firstline=' . get(l:opt, 'firstline', '') . ' downCursorline=' . l:cursorDown . ' height=' . l:height

    " move page
    if len(l:opt) > 0
        call popup_setoptions(a:id, l:opt)
    endif

    " move cursor
    while l:cursorRepeat > 0
        let l:cursorRepeat -= 1
        call popup_filter_menu(a:id, l:cursorMove)
    endwhile

    let a:context.index = l:index
    return v:true
endfunction

let s:listMenus = []

function! ListMenuInit(buffer, properties) abort
    let l:context = #{
        \ id: -1,
        \ index: 1,
        \ height: 10,
        \ onKey: 's:onKey',
      \ }

    let l:context.id = popup_menu(a:buffer, s:set(a:properties, l:context, #{
        \ filter: function('s:onFilter', [l:context]),
        \ hidden: v:true,
    \ }))

    let l:id = len(s:listMenus)
    call add(s:listMenus, l:context)

    return l:id
endfunction

function! ListMenuBuffer(id) abort
    if a:id < len(s:listMenus)
        return winbufnr(s:listMenus[a:id].id)
    endif
endfunction

function! s:set(properties, context, opt)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onKey'
            let a:context.onKey = l:value
        elseif l:key == 'height'
            let a:context.height = l:value
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

function! ListMenuOpen(id, properties) abort
    if a:id < len(s:listMenus)
        let l:context = s:listMenus[a:id]
        let l:context.index = 1
        call popup_setoptions(l:context.id, s:set(a:properties, l:context, #{firstline: 1}))
        call popup_show(l:context.id)
    endif
endfunction

function! ListMenuResume(id) abort
    if a:id < len(s:listMenus)
        call popup_show(s:listMenus[a:id].id)
    endif
endfunction


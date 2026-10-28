vim9script

if exists('g:loaded_consistent_popup')
    finish
endif
g:loaded_consistent_popup = 1

import "./rgQuery.vim" as rq
import "./bufferQuery.vim" as sq
import "./findQuery.vim" as fq
import "./list.vim" as li
import "./term.vim" as te
import "./nativeListQuery.vim" as nq
import "./pathQuery.vim" as pq
import "./assistant.vim" as as

# 1. Register text property highlights
var hl = {
    FileStyle: 'Statement',
    MatchStyle: 'Underlined',
    DirectoryStyle: 'Type',
    InputCursorStyle: 'Directory',
}->extend(get(g:, 'consistent_popup_highlights', {}))

for [prop, group] in items(hl)
    if empty(prop_type_get(prop))
        silent! prop_type_add(prop, {highlight: group, override: v:true})
    else
        silent! prop_type_change(prop, {highlight: group, override: v:true})
    endif
endfor

# 2. Pre-allocate List, Query types, Term, and Assistant
var list = li.List.new(get(g:, 'consistent_popup_list_height_ratio', 0.55))
var _rg = rq.AsyncRgQuery.new()
var _find = fq.AsyncFindQuery.new()
var _buffer = sq.BufferQuery.new()
var _path = pq.PathQuery.new()
var _qf = nq.NativeListQuery.new(' quickfix > ', (q) => getqflist())
var _loc = nq.NativeListQuery.new(' loclist > ', (q) => getloclist(get(q, 'winnr', 0)))

var term = te.Term.new(
    get(g:, 'consistent_popup_term_cmd', []),
    get(g:, 'consistent_popup_term_title', 'Terminal'),
    get(g:, 'consistent_popup_term_close_on_esc', v:false) ? 'HideTerm' : '',
    get(g:, 'consistent_popup_term_width', 0)
)
var assistant = as.Assistant.new()

# 3. Commands
command! -nargs=0 ListResume list.Resume()
command! -nargs=? ListGrep list.Call(_rg, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListFind list.Call(_find, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListBuffer list.Call(_buffer, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListPath list.Call(_path, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListQuickfix list.Call(_qf, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListLoclist list.Call(_loc, {
    \ keyword: <q-args>,
\ })

command! ShowTerm term.Show()
command! HideTerm term.Hide()

command! ShowAssistant assistant.Show()
command! HideAssistant assistant.Hide()
command! AssistantSendVisual assistant.SendVisual()

# 4. Editor Integration Autocmds (Quickfix interception, dirty tracking, cleanup)
def g:InterceptQuickfixWindow()
    if !get(g:, 'consistent_popup_intercept_quickfix', v:true)
        return
    endif

    var wtype = win_gettype()
    if wtype ==# 'autocmd' || wtype ==# 'popup'
        return
    endif

    var is_loc = wtype ==# 'loclist' || get(get(getwininfo(win_getid()), 0, {}), 'loclist', 0) == 1

    timer_start(0, (timer_id) => {
        if is_loc
            lclose
            execute 'ListLoclist'
        else
            cclose
            execute 'ListQuickfix'
        endif
    })
enddef

augroup ConsistentPopupHooks
    autocmd!
    autocmd BufWinEnter * if &buftype == 'quickfix' | g:InterceptQuickfixWindow() | endif
    autocmd BufWritePost * list.MarkDirty()
    autocmd QuitPre * term.Kill()
    autocmd QuitPre * assistant.Kill()
augroup END

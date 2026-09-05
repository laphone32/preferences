vim9script

import "../utils/rgQuery.vim" as rq
import "../utils/bufferQuery.vim" as sq
import "../utils/findQuery.vim" as fq
import "../utils/list.vim" as li
import "../utils/term.vim" as te
import "../utils/nativeListQuery.vim" as nq
import "../utils/pathQuery.vim" as pq
import "../utils/assistant.vim"

silent! prop_type_add('FileStyle', {highlight: 'Statement', override: v:true})
silent! prop_type_add('MatchStyle', {highlight: 'Underlined', override: v:true})
silent! prop_type_delete('DirectoryStyle')
silent! prop_type_add('DirectoryStyle', {highlight: 'Type', override: v:true})

var list = li.List.new(0.55)
var _rg = rq.AsyncRgQuery.new()
var _find = fq.AsyncFindQuery.new()
var _buffer = sq.BufferQuery.new()
var _path = pq.PathQuery.new()
var _qf = nq.NativeListQuery.new(' quickfix > ', (q) => getqflist())
var _loc = nq.NativeListQuery.new(' loclist > ', (q) => getloclist(get(q, 'winnr', 0)))

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

### Test
#command! -nargs=? ListTest ListAsyncRgCall({
#    \ keyword: empty(<q-args>) ? '.' : <q-args>,
#    \ commandName: 'test50',
#    \ sink: "printf \'%s\n\' {1..50}",
#    \ cursorOnMatch: v:false,
#    \ onPathFn: (data) => data.lines.text,
#    \ render: [(line) => ({ text: lookup[line].lines.text, }),],
#    \ mode: 0,
#\ })

### keymap
call AddListKeyMappings('find-file-call', 'ListFind', "ListFind %s")
call AddListKeyMappings('grep-file-call', 'ListGrep', 'ListGrep %s')
call AddListKeyMappings('find-buffer-call', 'ListBuffer', 'ListBuffer %s')
nnoremap <Plug>(resume-list-call) :ListResume<cr>
nnoremap <Plug>(file-manager-call) :ListPath<cr>

var term = te.Term.new()

command! ShowTerm term.Show()
command! HideTerm term.Hide()

nnoremap <Plug>(show-terminal-call) <c-w>:ShowTerm<cr>
tnoremap <Plug>(hide-terminal-call) <c-w>:HideTerm<cr>
autocmd QuitPre * term.Kill()

def g:InterceptQuickfixWindow()
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

augroup NativeQuickfixIntercept
    autocmd!
    autocmd BufWinEnter * if &buftype == 'quickfix' | g:InterceptQuickfixWindow() | endif
augroup END

augroup ListDirtyTracking
    autocmd!
    autocmd BufWritePost * list.MarkDirty()
augroup END



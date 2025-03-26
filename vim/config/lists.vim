vim9script

import "../utils/rgQuery.vim" as rq
import "../utils/bufferQuery.vim" as sq
import "../utils/findQuery.vim" as fq
import "../utils/list.vim" as li
import "../utils/term.vim" as te

prop_type_add('FileStyle', {highlight: 'Statement', override: v:true})
prop_type_add('MatchStyle', {highlight: 'Underlined', override: v:true})

var list = li.List.new(0.55)
var _rg = rq.AsyncRgQuery.new()
var _find = fq.AsyncFindQuery.new()
var _buffer = sq.BufferQuery.new()

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

var term = te.Term.new()

command! ShowTerm term.Show()
command! HideTerm term.Hide()

nnoremap <Plug>(show-terminal-call) :ShowTerm<cr>
tnoremap <Plug>(show-terminal-call) :HideTerm<cr>
autocmd QuitPre * term.Kill()


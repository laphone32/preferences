"""""""""""""""""""""""""""""""""""" NERDTree
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }

" Auto quit when choosing file to open
let NERDTreeQuitOnOpen=1
" Let statusline handle the status line
let g:NERDTreeStatusline = -1
" Sync the tree root and vim root
let NERDTreeChDirMode=2


" Open NERDTree in the directory of the current file (or /home if no file is open)
nnoremap <Plug>(file-manager-call) :call NERDTreeToggleInCurDir()<CR>
function! NERDTreeToggleInCurDir()
  " If NERDTree is open in the current buffer
  if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
    exe ":NERDTreeClose"
  else
    exe ":NERDTreeFind"
  endif
endfunction



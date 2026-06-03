vim9script

# NERDTree
# Auto quit when choosing file to open
g:NERDTreeQuitOnOpen = 1
# Let statusline handle the status line
g:NERDTreeStatusline = -1
# Sync the tree root and vim root
g:NERDTreeChDirMode = 2

# Open NERDTree in the directory of the current file (or /home if no file is open)
nnoremap <Plug>(file-manager-call) :call NERDTreeToggleInCurDir()<CR>

def g:NERDTreeToggleInCurDir()
    # If NERDTree is open in the current buffer
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
        execute 'NERDTreeClose'
    else
        execute 'NERDTreeFind'
    endif
enddef

augroup nerdTreeGroup
    autocmd!
    autocmd FileType nerdtree nnoremap <buffer> <esc> :NERDTreeClose<CR>
augroup end

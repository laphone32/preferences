"""""""""""""""""""""""""""""""""""""" vim-nord
let g:nord_uniform_diff_background = 1

augroup ColorOverwriteGroup
    autocmd!
    autocmd ColorScheme * highlight! link CocListLine CocFloatSbar
augroup end

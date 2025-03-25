"""""""""""""""""""""""""""""""""""""" vim-nord
let g:nord_uniform_diff_background = 1

augroup ColorOverrideGroup
    autocmd!
    autocmd ColorScheme nord highlight! link CocListLine CocFloatSbar
    autocmd ColorScheme nord highlight CocErrorHighlight guifg=Black
augroup end

colorscheme nord

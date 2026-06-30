vim9script

# Configuration for mattn/vim-lsp-settings

if !exists('g:lsp_settings')
    g:lsp_settings = {}
endif

# Customize clangd server parameters
g:lsp_settings['clangd'] = {
    'args': [
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu'
    ],
    'initialization_options': {
        'fallbackFlags': ['-std=c++20', '-Wall']
    }
}

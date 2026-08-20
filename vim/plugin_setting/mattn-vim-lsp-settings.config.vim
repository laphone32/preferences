vim9script

# Configuration for mattn/vim-lsp-settings

if !exists('g:lsp_settings')
    g:lsp_settings = {}
endif

# Customization
# clangd
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

# bash
g:lsp_settings['bash-language-server'] = {
    'allowlist': ['sh', 'bash'],
    'workspace_config': {
        'bashIde': {
            'includeAllWorkspaceSymbols': v:true,
            'globPattern': '**/*@(.sh|.inc|.bash|.command|*bashrc*|*bash_profile*|common*)'
        }
    }
}

# python
g:lsp_settings['pylsp-all'] = {
    'workspace_config': {
        'pylsp': {
            'plugins': {
                'pylint': {
			        'enabled': v:true,
                },
            }
        }
    }
}


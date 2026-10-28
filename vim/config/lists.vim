vim9script

# 1. Plugin Settings (for consistent_popup.vim)
g:consistent_popup_list_height_ratio = 0.55
g:consistent_popup_intercept_quickfix = v:true

g:consistent_popup_assistant = {
    title: 'Coding Assistant',
    width: 100,
    startup_delay: 3000,
    close_on_esc: v:true,
    cmd: (project_root: string): list<string> => {
        return ['bash', '-ic', 'agy --add-dir ' .. shellescape(project_root)]
    },
}

# 2. Keymap bindings (<Plug>(*-call) hooks used by config/keymap.vim)
g:AddListKeyMappings('find-file-call', 'ListFind', "ListFind %s")
g:AddListKeyMappings('grep-file-call', 'ListGrep', 'ListGrep %s')
g:AddListKeyMappings('find-buffer-call', 'ListBuffer', 'ListBuffer %s')
nnoremap <Plug>(resume-list-call) :ListResume<cr>
nnoremap <Plug>(file-manager-call) :ListPath<cr>

nnoremap <Plug>(show-terminal-call) <c-w>:ShowTerm<cr>
tnoremap <Plug>(hide-terminal-call) <c-w>:HideTerm<cr>

nnoremap <Plug>(show-assistant-call) <c-w>:ShowAssistant<cr>
tnoremap <Plug>(hide-assistant-call) <c-w>:HideAssistant<cr>
vnoremap <Plug>(visual-assistant-call) :<C-u>AssistantSendVisual<cr>

# 3. Load in-tree plugin entrypoint (remove once moved to dedicated plugin repo)
g:LoadConfig('utils/consistent_popup.vim')

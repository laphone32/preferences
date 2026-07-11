vim9script

import "./term.vim" as te

var assistant: te.Term = null_object

def GetAssistant(): te.Term
    if assistant == null_object
        # Get the project root synced by vim-rooter
        var project_root = getcwd()
        assistant = te.Term.new(['agy', '--add-dir', project_root], 'Coding Assistant', 'HideAssistant', 100)
    endif
    return assistant
enddef

def ShowAssistant()
    GetAssistant().Show()
enddef

def HideAssistant()
    if assistant != null_object
        assistant.Hide()
    endif
enddef

def SendVisualToAssistant()
    # 1. Gather file relative path and type
    var file_path = expand('%:.')
    var file_type = &filetype
    if empty(file_path)
        file_path = '[No Name]'
    endif

    # 2. Get line range of selection
    var start_line = line("'<")
    var end_line = line("'>")

    # 3. Yank selection to register without polluting user clipboard
    var saved_reg = getreg('"')
    var saved_type = getregtype('"')
    normal! gvy
    var text = getreg('"')
    setreg('"', saved_reg, saved_type)

    if empty(text)
        return
    endif

    var is_first_start = (assistant == null_object)

    # 4. Open/Get the assistant popup
    GetAssistant().Show()

    # 5. Format prompt with markdown header and code block
    var header = $"Code snippet from `{file_path}` (lines {start_line}-{end_line}):\n"
    var code_block = $"```{file_type}\n{text}\n```\n"
    var prompt = header .. code_block

    # 6. Feed context into terminal
    if is_first_start
        timer_start(3000, (_) => {
            term_sendkeys(GetAssistant().buffer, prompt)
        })
    else
        term_sendkeys(GetAssistant().buffer, prompt)
    endif
enddef

command! ShowAssistant ShowAssistant()
command! HideAssistant HideAssistant()
command! AssistantSendVisual SendVisualToAssistant()

# Plug mappings for the assistant
nnoremap <Plug>(show-assistant-call) <c-w>:ShowAssistant<cr>
tnoremap <Plug>(hide-assistant-call) <c-w>:HideAssistant<cr>
vnoremap <Plug>(visual-assistant-call) :<C-u>AssistantSendVisual<cr>

# Register startup & cleanup
augroup CodingAssistantHooks
    autocmd!
    autocmd QuitPre * if assistant != null_object | assistant.Kill() | endif
augroup END

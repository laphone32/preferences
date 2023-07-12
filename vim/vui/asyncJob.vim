
function! s:onTimer(context, id)
    if len(a:context.buffer) > 0
        call function(a:context.onData)(a:context.buffer)
        let a:context.buffer = []
    endif
endfunction

function! s:onOut(context, channel, message)
    let l:data = [a:message]
    let l:threshold = a:context.job.threshold

    if l:threshold > 0
        call function(a:context.onData)(l:data)
        let a:context.job.threshold = l:threshold - 1
    else
        let a:context.buffer = a:context.buffer + l:data
        if l:threshold == 0
            let a:context.timer.id = timer_start(a:context.timer.period, function('s:onTimer', [a:context]), #{repeat: -1})
            let a:context.job.threshold = -1
        endif
    endif
endfunction

let s:asyncJobs = []

function! AsyncJobRun(properties) abort
    let l:context = #{
        \ buffer: [],
        \ onData: '',
        \ job: #{
            \ id: -1,
            \ threshold: 20,
        \ },
        \ timer: #{
            \ id: -1,
            \ period: 10,
      \ }
    \ }

    let l:cmd = ['/bin/sh', '-c', "echo \'No command for async job\'"]

    for [l:key, l:value] in items(a:properties)
        if l:key == 'onData'
            let l:context.onData = l:value
        elseif l:key == 'threshold'
            let l:context.job.threshold = l:value
        elseif l:key == 'cmd'
            let l:cmd = l:value
        endif
    endfor

    let l:id = len(s:asyncJobs)
    let s:asyncJobs = s:asyncJobs + [l:context]

    let s:asyncJobs[l:id].job.id = job_start(l:cmd, #{
            \ pty: 1,
            \ out_cb: function('s:onOut', [s:asyncJobs[l:id]]),
          \ })
endfunction

function! AsyncJobStop(id) abort
    if a:id < len(s:asyncJobs)
        let l:job = s:asyncJobs[a:id]
        if l:job.job.id != -1
            call job_stop(l:job.job.id)
            let s:asyncJobs[a:id].job.id = -1
        endif

        if l:job.timer.id != -1
            call timer_stop(l:job.timer.id)
            let s:asyncJobs[a:id].timer.id = -1
        endif
    endif
endfunction



function! s:onData(data) abort
endfunction

function! s:onTimer(context, id) abort
    if len(a:context.buffer) > 0
        call function(a:context.onData)(a:context.buffer)
        let a:context.buffer = []
    endif
endfunction

function! s:onOut(context, channel, message) abort
    if a:context.job.threshold > 0
        call function(a:context.onData)([a:message])
        let a:context.job.threshold -= 1
    else
        call add(a:context.buffer, a:message)
        if a:context.job.threshold == 0
            let a:context.timer.id = timer_start(a:context.timer.period, function('s:onTimer', [a:context]), #{repeat: -1})
            let a:context.job.threshold = -1
        endif
    endif
endfunction

let s:asyncJobs = []

function! AsyncJobRun(properties) abort
    let l:context = #{
        \ buffer: [],
        \ onData: 's:onData',
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

    let l:context.job.id = job_start(l:cmd, #{
            \ pty: 1,
            \ out_cb: function('s:onOut', [l:context]),
          \ })

    let l:id = len(s:asyncJobs)
    call add(s:asyncJobs, l:context)


    return l:id
endfunction

function! AsyncJobStop(id) abort
    if a:id < len(s:asyncJobs)
        let l:job = s:asyncJobs[a:id]
        if l:job.job.id isnot# -1
            call job_stop(l:job.job.id)
            let l:job.job.id = -1
        endif

        if l:job.timer.id isnot# -1
            call timer_stop(l:job.timer.id)
            let l:job.timer.id = -1
        endif

        let l:job.buffer = []
    endif
endfunction



function! s:onTimer(context, id) abort
    if len(a:context.buffer) > 0
        call function(a:context.onData)(a:context.buffer)
        let a:context.buffer = []
    endif
endfunction

function! s:onOut(context, channel, message) abort
    if a:context.job.thresholdCount < a:context.job.threshold
        call function(a:context.onData)([a:message])
        let a:context.job.thresholdCount += 1
    else
        call add(a:context.buffer, a:message)
        if a:context.job.thresholdCount == a:context.job.threshold
            let a:context.timer.id = timer_start(a:context.timer.period, function('s:onTimer', [a:context]), #{repeat: -1})
            let a:context.job.thresholdCount = a:context.job.threshold + 1
        endif
    endif
endfunction

let s:asyncJobs = []

function! AsyncJobInit(properties) abort
    let l:context = #{
        \ buffer: [],
        \ onData: get(a:properties, 'onData', { _ -> return }),
        \ job: #{
            \ id: -1,
            \ threshold: get(a:properties, 'threshold', 20),
            \ thresholdCount: 0,
        \ },
        \ timer: #{
            \ id: -1,
            \ period: 10,
      \ }
    \ }

    let l:id = len(s:asyncJobs)
    call add(s:asyncJobs, l:context)

    return l:id
endfunction

function! AsyncJobRun(id, properties) abort
    if a:id < len(s:asyncJobs)
        call AsyncJobStop(a:id)

        let l:context = s:asyncJobs[a:id]

        let l:context.onData = get(a:properties, 'onData', l:context.onData)
        let l:context.job.threshold = get(a:properties, 'threshold', l:context.job.threshold)
        let l:context.job.id = job_start(get(a:properties, 'cmd', ['/bin/sh', '-c', "echo \'No command for async job\'"]), #{
                \ pty: 1,
                \ out_cb: function('s:onOut', [l:context]),
            \ })
    endif
endfunction

function! AsyncJobStop(id) abort
    if a:id < len(s:asyncJobs)
        let l:context = s:asyncJobs[a:id]
        if l:context.job.id isnot# -1
            call job_stop(l:context.job.id)
            let l:context.job.id = -1
        endif
        let l:context.job.thresholdCount = 0

        if l:context.timer.id isnot# -1
            call timer_stop(l:context.timer.id)
            let l:context.timer.id = -1
        endif

        let l:context.buffer = []
    endif
endfunction


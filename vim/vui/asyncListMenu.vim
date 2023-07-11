
function! s:onTimer(properties, id)
    if len(a:properties.job.buffer) > 0
        call function(a:properties.job.onData)(a:properties.job.buffer)
        let a:properties.job.buffer = []
    endif
endfunction

function! s:onOut(properties, channel, message)
    let l:count = a:properties.job.count + 1
    let l:data = [a:message]
    let l:batchSize = a:properties.job.batchSize

    if l:count < l:batchSize
        call function(a:properties.job.onData)(l:data)
    else
        if l:count == l:batchSize
            let a:properties.timer.id = timer_start(10, function('s:onTimer', [s:asyncListMenuProperties]), #{repeat: -1})
        endif
        let a:properties.job.buffer = a:properties.job.buffer + l:data
    endif

    let a:properties.job.count = l:count
endfunction

let s:asyncListMenuProperties = #{
    \ job: #{
        \ id: 0,
        \ cmd: '',
        \ onData: '',
        \ batchSize: 10,
        \ count: 0,
        \ buffer: [],
        \ opt: #{
            \ pty: 1,
            \ out_cb: 's:onOut',
          \ },
    \ },
    \ timer: #{
        \ id: 0,
      \ }
  \ }

function! AsyncListMenuInit(properties)
    call ListMenuInit(a:properties)

    call s:set(a:properties)
endfunction

function! AsyncListMenuReset()
    if s:asyncListMenuProperties.job.id != 0
        call job_stop(s:asyncListMenuProperties.job.id)
        let s:asyncListMenuProperties.job.id = 0
    endif

    if s:asyncListMenuProperties.timer.id != 0
        call timer_stop(s:asyncListMenuProperties.timer.id)
        let s:asyncListMenuProperties.timer.id = 0
    endif

    let s:asyncListMenuProperties.job.count = 0
endfunction

function! s:set(properties)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'onData'
            let s:asyncListMenuProperties.job.onData = l:value
        elseif l:key == 'height'
            let s:asyncListMenuProperties.job.batchSize = l:value
        elseif l:key == 'cmd'
            let s:asyncListMenuProperties.job.cmd = l:value
        endif
    endfor
endfunction

function! AsyncListMenuOpen(properties) abort
    call AsyncListMenuReset()
    call s:set(a:properties)

    let s:asyncListMenuProperties.job.opt.out_cb = function('s:onOut', [s:asyncListMenuProperties])
    let s:asyncListMenuProperties.job.id = job_start(s:asyncListMenuProperties.job.cmd, s:asyncListMenuProperties.job.opt)
    call ListMenuOpen(a:properties)
endfunction

function! AsyncListMenuResume() abort
    call ListMenuResume()
endfunction


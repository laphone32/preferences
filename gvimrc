" Set GUI fonts
" Monaco / Hermit / Droid Sans Mono / Source Code Pro 
if g:os == 'Linux'
    set guifont=Hermit\ bold\ 20
else
    set guifont=Hermit:h20
endif

" Without toolbar
set guioptions-=T
" Without gui tabbar, always use modified text tabbar
set guioptions-=e
" Without menubar
set guioptions-=m
" Without auto select/copy
set guioptions-=a
set guioptions-=A
set guioptions-=aA
" Disable scrollbars
set guioptions-=r
set guioptions-=L
" Disable all cursor blinking
"set guicursor+=a:blinkon0
" Startup in full screen size
" au GUIEnter * simalt ~x
if has("gui_running")
    " GUI is running or is about to start.
    " Maximize gvim window.
    set lines=99 columns=999
endif


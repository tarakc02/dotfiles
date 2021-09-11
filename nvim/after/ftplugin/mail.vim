setlocal wrap linebreak
setlocal nocursorline nolist

vmap j gj
vmap k gk
vmap $ g$
vmap ^ g^
vmap 0 g0
nmap j gj
nmap k gk
nmap $ g$
nmap ^ g^
nmap 0 g0

inoremap <expr> <c-x><c-l> fzf#vim#complete(fzf#wrap({
            \ 'prefix': '^From:(.*)$',
            \ 'source': 'notmuch address "*"',
            \ 'options': '--multi --reverse --margin 15%,0',
            \ 'reducer': { lines -> join(lines, ',')} }))

command! Preview :% !my preview-mail
command! WeeklyList :read !notmuch address --output=recipients from:tarak date:last_week subject:"TS week of" | sed 's/$/,/g'

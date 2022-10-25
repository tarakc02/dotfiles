setlocal wrap linebreak textwidth=79
setlocal nocursorline nolist
setlocal spell spelllang=en_us

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

command! Preview :% !my preview-md

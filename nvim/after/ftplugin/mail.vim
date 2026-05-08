setlocal wrap linebreak
setlocal nocursorline nolist
setlocal spell spelllang=en_us
setlocal colorcolumn=72

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

inoremap <buffer><silent> <c-x><c-l> <cmd>lua require'fzf-lua'.fzf_exec("notmuch address '*'", {
            \ prompt = "Address> ",
            \ fzf_opts = { ["--multi"] = true, ["--reverse"] = true },
            \ winopts = { height = 0.6, width = 0.7 },
            \ complete = function(selected, _, line, col)
            \   if not selected or #selected == 0 then return end
            \   local text = table.concat(selected, ", ")
            \   local before = line:sub(1, col)
            \   local after = #line > col and line:sub(col + 1) or ""
            \   return before .. text .. after, col + #text
            \ end,
            \ })<CR>

command! Preview :% !my preview-mail
command! WeeklyList :read !notmuch address --output=recipients from:tarak date:last_week subject:"TS week of" | sed 's/$/,/g'

set dictionary=/usr/share/dict/words


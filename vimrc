set nocompatible
set hidden
set termguicolors
syntax enable
let maplocalleader = ','

"layout
set relativenumber number
set colorcolumn=80

" tabs
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set smartindent

" makefiles use tabs
if &ft == 'make'
    setlocal noexpandtab
    setlocal tabstop=4
endif

" cursor shape
let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

"color
highlight Pmenu ctermbg=gray gui=bold
highlight PmenuSel ctermbg=lightcyan gui=bold
highlight ColorColumn ctermbg=232 guibg=#2c2d27
highlight SignColumn ctermbg=none guibg=none
highlight SignatureMarkText ctermbg=none guibg=none
highlight LineNr ctermfg=grey
highlight LineNr cterm=italic
highlight Comment cterm=italic 

"search/replace
set ignorecase
set smartcase

call plug#begin('~/.local/share/nvim/plugged')

Plug 'jalvesaq/Nvim-R'
Plug 'kshenoy/vim-signature'
Plug 'vim-airline/vim-airline'

"Options related to Nvim-R
vmap <Space> <Plug>RDSendSelection
nmap <Space> <Plug>RDSendLine
vmap <LocalLeader>c <Plug>RToggleComment
nmap <LocalLeader>c <Plug>RToggleComment
inoremap <LocalLeader><LocalLeader> <C-x><C-o>
let R_assign = 0
let R_nvim_wd = 1

"show buffers, navigate with Tab/Shift+Tab
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

"window navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

colorscheme monokai
let g:monokai_term_italic = 1
let g:monokai_gui_italic = 1
set completeopt=noinsert,menuone,noselect

call plug#end()

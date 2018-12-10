set nocompatible
set hidden
set termguicolors
syntax enable
let maplocalleader = ','

"layout
set relativenumber number
set colorcolumn=80

"focus
function! s:DimInactiveWindow()
    set norelativenumber number
    let &l:colorcolumn='+' . join(range(0, 255), ',')
endfunction

function! s:UndimActiveWindow()
    set colorcolumn=80
    set relativenumber number
endfunction

autocmd WinEnter * call s:UndimActiveWindow()
autocmd BufEnter * call s:UndimActiveWindow()
autocmd WinLeave * call s:DimInactiveWindow()

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

" terminal mode
tnoremap <Esc> <C-\><C-n>

" close brackets/parens/quotes
inoremap ( ()<C-G>U<Left>
inoremap [ []<C-G>U<Left>
inoremap { {}<C-G>U<Left>
inoremap " ""<C-G>U<Left>
inoremap ' ''<C-G>U<Left>
inoremap <expr>) getline('.')[col('.')-1] == ")" ? "\<C-G>U<Right>" : ")"
inoremap <expr>] getline('.')[col('.')-1] == "]" ? "\<C-G>U<Right>" : "]"
inoremap <expr>} getline('.')[col('.')-1] == "}" ? "\<C-G>U<Right>" : "}"
inoremap <expr>' strpart(getline('.'), col('.')-1, 1) == "\'" ? "\<Right>" : "\'\'\<Left>"
inoremap <expr>" strpart(getline('.'), col('.')-1, 1) == "\"" ? "\<Right>" : "\"\"\<Left>"

"search/replace
set ignorecase
set smartcase

call plug#begin('~/.local/share/nvim/plugged')

Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-path'
Plug 'jalvesaq/Nvim-R'
Plug 'gaalcaras/ncm-R'
Plug 'sirver/UltiSnips'
Plug 'ncm2/ncm2-ultisnips'
Plug 'honza/vim-snippets'
Plug 'vim-airline/vim-airline'
Plug 'Yavor-Ivanov/airline-monokai-subtle.vim'

"Options related to Nvim-R
vmap <Space> <Plug>RDSendSelection
nmap <Space> <Plug>RDSendLine
vmap <LocalLeader>c <Plug>RToggleComment
nmap <LocalLeader>c <Plug>RToggleComment
let R_assign = 0
let R_nvim_wd = 1

"status line via airline
let g:airline_section_b = '%-0.40{getcwd()}'
let g:airline_section_c = "%f"

"show buffers, navigate with Tab/Shift+Tab
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_theme = 'monokai_subtle'
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

autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect

inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')

" c-j c-k for moving in snippet
let g:UltiSnipsExpandTrigger	    = "<C-s>"
let g:UltiSnipsJumpForwardTrigger	= "<c-j>"
let g:UltiSnipsJumpBackwardTrigger	= "<c-k>"
"let g:UltiSnipsRemoveSelectModeMappings = 0
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

call plug#end()

" a new comment
set nocompatible
set cursorline
set hidden
set termguicolors
syntax enable
let maplocalleader = ','

nnoremap <LocalLeader><LocalLeader> ,
"layout
set relativenumber number
set colorcolumn=80
set list
set listchars=tab:▸\ ,eol:¬,nbsp:·,trail:·

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

autocmd TermOpen * set nobuflisted

" edited this out b/c it makes it slow to open nvim
"set shell=bash\ -l

" tabs
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set smartindent

" makefiles use tabs
augroup makefile_mappings
    autocmd!
    autocmd FileType make setlocal noexpandtab tabstop=4
augroup END

" long lines in markdown/tex
augroup markdown_navigation
    autocmd!
    autocmd FileType markdown,rmd,tex set wrap linebreak nolist
    autocmd FileType markdown,rmd,tex vmap j gj
    autocmd FileType markdown,rmd,tex vmap k gk
    autocmd FileType markdown,rmd,tex vmap $ g$
    autocmd FileType markdown,rmd,tex vmap ^ g^
    autocmd FileType markdown,rmd,tex vmap 0 g0
    autocmd FileType markdown,rmd,tex nmap j gj
    autocmd FileType markdown,rmd,tex nmap k gk
    autocmd FileType markdown,rmd,tex nmap $ g$
    autocmd FileType markdown,rmd,tex nmap ^ g^
    autocmd FileType markdown,rmd,tex nmap 0 g0
augroup END

" cursor shape
let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

" terminal mode
tnoremap <Esc> <C-\><C-n>

" colors
" dark0 + gray
"let g:terminal_color_0 = "#272822"
"let g:terminal_color_8 = "#8F908A"
"
"" neurtral_red + bright_red
"let g:terminal_color_1 = "#e73c50"
"let g:terminal_color_9 = "#5f0000"
"
"" neutral_green + bright_green
"let g:terminal_color_2 = "#b8bb26"
"let g:terminal_color_10 = "#98971a"
"
"" neutral_yellow + bright_yellow
"let g:terminal_color_3 = "#E6DB74"
"let g:terminal_color_11 = "#FD9720"
"
"" neutral_blue + bright_blue
"let g:terminal_color_4 = "#66d9ef"
"let g:terminal_color_12 = "#83a598"
"
"" neutral_purple + bright_purple
"let g:terminal_color_5 = "#b16286"
"let g:terminal_color_13 = "#d3869b"
"
"" neutral_aqua + faded_aqua
"let g:terminal_color_6 = "#689d6a"
"let g:terminal_color_14 = "#8ec07c"
"
"" light4 + light1
"let g:terminal_color_7 = "#E8E8E3"
"let g:terminal_color_15 = "#575b61"

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

let known_pairs = { "{}": "", "[]": "", "()": "", "\"\"": "", "''": "" }
inoremap <expr><BS> has_key(known_pairs, getline('.')[col('.')-2:col('.')-1]) ? "\<C-G>U<Right><BS><BS>" : "\<BS>"

"search/replace
set ignorecase
set smartcase

"use git grep
set grepprg=git\ grep\ --break\ -n\ -r\ $*\ --\ :/

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
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'dir': '~/git/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

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
let g:airline#extensions#tabline#buffer_nr_show=1
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
let g:UltiSnipsSnippetDirectories   = ["UltiSnips", "my-snippets"]
let g:UltiSnipsSnippetsDir           = $HOME . "/.config/nvim/my-snippets"
"let g:UltiSnipsRemoveSelectModeMappings = 0
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

call plug#end()

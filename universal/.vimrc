" setup pathogen
set nocompatible
filetype off

" get rid of annoying 'Flying Vim' title and system beep
set titleold=~
set noeb vb t_vb=

autocmd BufEnter * let &titlestring = $HOSTNAME . ":" . expand("%:p:~")


" look and color
syntax enable
set background=dark
colorscheme default
set title
set nowrap
set hidden
set guioptions-=T

set t_Co=256
set encoding=utf-8

" persistent undo
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","


" Fast saving
nmap <leader>w :w!<cr>


" paste toggle
nnoremap <F3> :set invpaste paste?<CR>
set pastetoggle=<F3>
set showmode

" common helpful settings
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set ruler
set showmatch

" tabs & indent
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

autocmd FileType php setlocal shiftwidth=2 softtabstop=2

" folding
set foldmethod=indent
set foldnestmax=3
set nofoldenable

" search
set incsearch
set ignorecase
set smartcase
set hlsearch
"clearing highlighted search
nmap <silent> <leader>/ :nohlsearch<CR>

" scroll
set scrolljump=5
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

" UI
" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

imap jk <Esc>

" Stupid shift key fixes
cmap W w                        
cmap WQ wq
cmap wQ wq
cmap Q q
cmap Tabe tabe

" Other stuff

augroup filetypedetect
   au! BufRead,BufNewFile *httpd*.conf     setfiletype apache
   au! BufRead,BufNewFile *inc     setfiletype php
   au! BufRead,BufNewFile *.ctp     setfiletype php
augroup END


if &term == "xterm-color"
  fixdel
endif

set formatoptions=qrct

set nobackup
set nowb
set noswapfile
set laststatus=2
set noshowmode

filetype plugin indent on

" plugin toggles and mappings
map <F2> :NERDTreeToggle<CR>
:nmap <C-e> :e#<CR>
:nmap ; :Unite -start-insert buffer<CR>
:nmap \e :NERDTreeToggle<CR>

" fugitive
map <leader>gs :Gstatus<cr>
map <leader>gd :Gdiff<cr>
map <leader>gc :Gcommit -a<cr>


" CtrlP Settings
:let g:ctrlp_map = '<Leader>t'
:let g:ctrlp_match_window_bottom = 0
:let g:ctrlp_match_window_reversed = 0
:let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
:let g:ctrlp_working_path_mode = 0
:let g:ctrlp_dotfiles = 0
:let g:ctrlp_switch_buffer = 0


" COLORS {
        " syntax highlighting groups
        hi Comment      ctermfg=12
        hi Constant     ctermfg=6 
        hi Identifier   ctermfg=4
        hi Statement    ctermfg=2
        hi PreProc      ctermfg=1
        hi Type         ctermfg=3
        hi Special      ctermfg=5
        hi Underlined   ctermfg=7
        hi Ignore       ctermfg=9
        hi Error        ctermfg=11
        hi Todo         ctermfg=1
        hi Normal ctermfg=none ctermbg=none
        hi NonText ctermfg=0 ctermbg=none
        hi Directory    ctermfg=12

        hi VertSplit    ctermfg=black
        hi StatusLine   ctermfg=white
        hi StatusLineNC ctermfg=0 

        hi Pmenu ctermfg=10 ctermbg=0
        hi PmenuSel ctermfg=0 ctermbg=14
        hi LineNr ctermfg=3 ctermbg=0
        hi CursorLine ctermfg=none ctermbg=16 cterm=none
        hi CursorLineNr ctermfg=5 ctermbg=0 
        hi CursorColumn ctermfg=none ctermbg=0
"}

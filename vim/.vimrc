" Last update:  Tue Oct 10 15:13:27 CST 2017
" Github: https://github.com/Karmenzind/MyConfig

" --------------------------------------------------
"  Plugins Manage
" --------------------------------------------------

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'tmhedberg/SimpylFold'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'gmarik/Vundle.vim'   " let Vundle manage Vundle, required
Plugin 'nvie/vim-flake8'
Plugin 'kien/ctrlp.vim'  " search file inside vim
Plugin 'Chiel92/vim-autoformat'

" Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'} " a status bar

" All of your Plugins must be added before the following line
call vundle#end()            
filetype plugin indent on    


" --------------------------------------------------
" Basic
" --------------------------------------------------

"colorscheme molokai

set nocompatible              

set encoding=utf-8

set nu

set cursorline

set history=1000

" This shows what you are typing as a command.  
set showcmd

" Enable mouse support in console
set mouse=a


"Status line gnarliness
"set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

" --------------------------------------------------
"  coding
" --------------------------------------------------

" Spaces are better than a tab character
set expandtab
set smarttab

set showmatch

" Enable folding
set foldmethod=indent
set foldlevel=99
let g:SimpylFold_docstring_preview=1

" hl useless whitespaces
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/
highlight BadWhitespace ctermbg=red guibg=darkred

" Use english for spellchecking, but don't spellcheck by default
if version >= 700
   set spl=en spell
   set nospell
endif

" --------------------------------------------------
"  File
" --------------------------------------------------

" backup
"set backup
"set backupdir=~/tmp/vim_backup/
"set directory=~/.vim/tmp

set splitbelow
set splitright

" file type detection
filetype off                 

" hide pyc in NERDTREE
let g:NERDTreeIgnore=['\.pyc$', '\~$']


" --------------------------------------------------
" for python
" --------------------------------------------------

let python_highlight_all=1
syntax on

" PEP8 intent
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2


" --------------------------------------------------
" ycm config
" --------------------------------------------------

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_python_binary_path='/usr/bin/python3'
let g:ycm_server_python_interpreter='/usr/bin/python'
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'

" key mappings
nnoremap <leader>jd :YcmCompleter GoTo<CR>'


" --------------------------------------------------
" other plugin config
" --------------------------------------------------

" For vim-autoformatter
let g:formatter_yapf_style = 'pep8'

" --------------------------------------------------
" reference
" --------------------------------------------------

" https://stackoverflow.com/questions/164847/what-is-in-your-vimrc
" https://segmentfault.com/a/1190000003962806

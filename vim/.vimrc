" Last update:  2018-02-12
" Github: https://github.com/Karmenzind/MyConfig

set nocompatible

" file type detection
filetype off 

" --------------------------------------------------
"  Plugins Manage
" --------------------------------------------------

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'VundleVim/Vundle.vim'
Plugin 'tmhedberg/SimpylFold'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'nvie/vim-flake8'
Plugin 'kien/ctrlp.vim'  " search file inside vim
Plugin 'Chiel92/vim-autoformat'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'morhetz/gruvbox'
Plugin 'plytophogy/vim-virtualenv'
Plugin 'wsdjeg/FlyGrep.vim'
Plugin 'Yggdroot/LeaderF'

" /Alternative/
" Plugin 'SirVer/ultisnips' " ultimate solution for snippets
" Plugin 'davidhalter/jedi-vim'
" Plugin 'vim-scripts/fcitx.vim' " keep and restore fcitx state when leaving/re-entering insert mode
" Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}  a status bar
" Plugin 'rkulla/pydiction' " Python Tab-completion 
" Plugin 'ctrlpvim/ctrlp.vim'

" All of your Plugins must be added before the following line
call vundle#end()            
filetype plugin indent on    


" --------------------------------------------------
" Basic
" --------------------------------------------------

syntax on

" colorscheme Tomorrow-Night-Eighties
" colorscheme Tomorrow-Night-Bright

" colorscheme molokai
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1
colorscheme solarized

set background=dark

set cursorline
" highlight CursorLine guibg=darkgray ctermbg=black

set encoding=utf-8

set nu


set history=1000

" This shows what you are typing as a command.  
set showcmd

" Enable mouse support in console
set mouse=a

" status line if there is more than one window
set laststatus=2

"Status line gnarliness
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

" --------------------------------------------------
"  coding
" --------------------------------------------------

" Spaces are better than a tab character
set expandtab
set smarttab
set tabstop=4 
set softtabstop=4 
set shiftwidth=4

" set showmatch

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

" --------------------------------------------------
" format for specific file type
" --------------------------------------------------

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
" for Python
" --------------------------------------------------

let python_highlight_all=1

"python with virtualenv support
py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF

" --------------------------------------------------
" for ycm
" --------------------------------------------------

let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_python_binary_path='python'
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'

" for ycmd server, not completion
let g:ycm_server_python_interpreter='/usr/bin/python2'

" key mappings
nnoremap <leader>gt :YcmCompleter GoTo<CR>'
map <leader>dd  :YcmCompleter GoToDefinitionElseDeclaration<CR>
map <leader>rf  :YcmCompleter GoToReferences<CR>
map <leader>doc  :YcmCompleter GetDoc<CR>

" --------------------------------------------------
" for NERDTree
" --------------------------------------------------

" How can I map a specific key or shortcut to open NERDTree?
map <C-n> :NERDTreeToggle<CR>

" How can I change default arrows?
" let g:NERDTreeDirArrowExpandable = '▸'
" let g:NERDTreeDirArrowCollapsible = '▾'

" How can I open a NERDTree automatically when vim starts up?
" autocmd vimenter * NERDTree

" How can I open a NERDTree automatically when vim starts up if no files were specified?
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" How can I open NERDTree automatically when vim starts up on opening a directory?
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" How can I close vim if the only window left open is a NERDTree?
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" hide specific files in NERDTREE
let g:NERDTreeIgnore=['\.pyc$', 
            \'\~$',
            \'__pycache__[[dir]]']

let NERDTreeNaturalSort=1 
let NERDTreeShowLineNumbers=1
" let NERDTreeMinimalUI=1

" --------------------------------------------------
" other plugin config
" --------------------------------------------------

" For vim-airline
let g:airline_theme="minimalist"

" For vim-autoformatter
let g:formatter_yapf_style = 'pep8'

" For vim-virtualenv
let g:virtualenv_directory = '~/Envs'

" for jedi-vim
" let g:jedi#use_splits_not_buffers = "right"
" let g:jedi#completions_command = "<leader><Space>"

" for LeaderF
" let g:Lf_ShortcurF = '<leader>n'
nnoremap <leader>f :LeaderfFile<cr>
highlight Lf_hl_match gui=bold guifg=Blue cterm=bold ctermfg=21
highlight Lf_hl_matchRefine  gui=bold guifg=Magenta cterm=bold ctermfg=201
let g:Lf_WindowPosition = 'bottom'
let g:Lf_DefaultMode = 'FullPath'
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_WildIgnore = {
    \ 'dir': ['.svn','.git','.hg', '.idea', '__pycache__'],
    \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
    \}
let g:Lf_MruFileExclude = ['*.so']
" let g:Lf_PreviewCode = 0

" for FlyGrep
" nnoremap <leader>f :FlyGrep<cr>
nnoremap <leader>s :FlyGrep<cr>

" --------------------------------------------------
" reference
" --------------------------------------------------

" https://stackoverflow.com/questions/164847/what-is-in-your-vimrc
" https://segmentfault.com/a/1190000003962806


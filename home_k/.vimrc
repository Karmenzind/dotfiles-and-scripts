" Github: https://github.com/Karmenzind/dotfiles-and-scripts

" --------------------------------------------
" general keymap
" --------------------------------------------

noremap <leader>e  :tabe   $MYVIMRC<cr>
noremap <leader>R  :source $MYVIMRC<cr>
noremap <leader>pi :source $MYVIMRC<cr> :PlugInstall<cr>
noremap <leader>pu :source $MYVIMRC<cr> :PlugUpdate<cr>
noremap <leader>ps :source $MYVIMRC<cr> :PlugStatus<cr>
noremap <leader>pc :source $MYVIMRC<cr> :PlugClean<cr>

" -----------------------------------------------------------------------------
"  Plugin Manager
" -----------------------------------------------------------------------------

" automatically install Plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !mkdir -p ~/.vim/autoload &&
    \ wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    \ -O ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
if empty(glob('~/.vim/.ycm_extra_conf.py'))
  silent !wget https://raw.githubusercontent.com/Karmenzind/dotfiles-and-scripts/master/home_k/.vim/.ycm_extra_conf.py 
    \-O ~/.vim/.ycm_extra_conf.py
endif

call plug#begin()

Plug 'junegunn/vim-plug'
Plug 'flazz/vim-colorschemes', { 'do': 'rsync -avz ./colors/ ~/.vim/colors/ && rm -rf ./colors/*' }
Plug 'chxuan/change-colorscheme', { 'on': 'NextColorScheme' }

Plug 'vim-scripts/txt.vim', { 'for': 'txt' }
Plug 'tpope/vim-endwise'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang --go-completer --js-completer --java-completer' }
Plug 'SirVer/ultisnips' 
Plug 'honza/vim-snippets'
Plug 'Chiel92/vim-autoformat'

Plug 'Shougo/context_filetype.vim'
Plug 'Shougo/echodoc.vim'

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'wsdjeg/FlyGrep.vim'
Plug 'Yggdroot/LeaderF'
Plug 'easymotion/vim-easymotion'

Plug 'airblade/vim-gitgutter'

Plug 'rkulla/pydiction', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' } " code folding for Python
Plug 'nvie/vim-flake8', { 'for': 'python' } " Python syntax checker (flake8 required) [press F7 to run]
Plug 'vim-scripts/indentpython.vim', { 'for': 'python' }
Plug 'plytophogy/vim-virtualenv', { 'for': 'python' } " Python v e

Plug 'terryma/vim-smooth-scroll' 
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'junegunn/vim-slash'
Plug 'majutsushi/tagbar'
Plug 'mhinz/vim-startify'

Plug 'hallison/vim-markdown'
Plug 'iamcco/mathjax-support-for-mkdp', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.vim', { 'for': 'markdown' }

" load after other plugins 
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" /* Alternative */
" Plug 'junegunn/vim-emoji' ", { 'for': 'markdown' }
" Plug 'Valloric/MatchTagAlways'
" Plug 'python-mode/python-mode'
" Plug 'w0rp/ale' "Asynchronous Lint Engine
" Plug 'junegunn/fzf' | Plug 'junegunn/fzf.vim'
" Plug 'junegunn/fzf', {'dir': '~/.local/fzf', 'do': './install --all'}
" Plug 'bagrat/vim-workspace' " tab bar
" Plug 'morhetz/gruvbox'
" Plug 'junegunn/limelight.vim'
" Plug 'junegunn/rainbow_parentheses.vim'
" Plug 'vim-scripts/fcitx.vim' " keep and restore fcitx state when leaving/re-entering insert mode
" Plug 'python-mode/python-mode'

call plug#end()            

" load vim default plugin
runtime macros/matchit.vim

" --------------------------------------------
" basic
" --------------------------------------------

set nocompatible
set noerrorbells

set report=0

" encode
set termencoding=utf-8
set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030
set encoding=utf-8

" appearence
set ruler
set showtabline=1
syntax enable
syntax on
set guifont=Monaco\ Nerd\ Font\ Mono\ Regular\ 12
set background=dark
" gruvbox bubblegum birds-of-paradise blaquemagick buddy_modified dante eclipse darkburn enigma eva01 evening evolution 1989
colo solarized
set cursorline
" highlight CursorLine guibg=darkgray ctermbg=black
set nu
set noshowmode
" set cmdheight=2
" status line if there is more than one window
set laststatus=2
set nowrap
" set whichwrap+=<,>,h,l

" layout
set splitbelow
set splitright

" This shows what you are typing as a command.  
set showcmd

" operate
" Enable mouse support in console
set mouse=a

set matchtime=5 
set iskeyword+=_,$,@,%,#,-

" Status line gnarliness
" set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

" filetype plugin on

" -----------------------------------------------------------------------------
"  coding
" -----------------------------------------------------------------------------

set wildmenu

" Spaces are better than a tab character
set expandtab
set smarttab
set tabstop=4 
set softtabstop=4 
set shiftwidth=4

" set showmatch

" Enable folding
" set foldmethod=indent
set foldmethod=manual
set foldlevel=99
let g:SimpylFold_docstring_preview=1

" hl useless whitespaces
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/
highlight BadWhitespace ctermbg=red guibg=darkred

" Use english for spellchecking, but don't spellcheck by default
set spl=en spell
set nospell

" -----------------------------------------------------------------------------
"  File
" -----------------------------------------------------------------------------

set history=1000

set nobackup
" set noswapfile          
" set autoread            
" set autowrite           
" set confirm             

" autocmd BufNewFile,BufRead *.{md,mkd,mkdn,mark*} set filetype=markdown

" -----------------------------------------------------------------------------
" header
" -----------------------------------------------------------------------------

function! HeaderPy()
     call setline(1, "# !/usr/bin/env python")
     call append(1, "# -*- coding: utf-8 -*-")
     "call append(2, "# Created at: " . strftime('%Y-%m-%d %T', localtime()))
     normal G2o
 endf
 autocmd bufnewfile *.py call HeaderPy()

function! HeaderBash()
     call setline(1, "# !/usr/bin/env bash")
     normal G2o
 endf
 autocmd bufnewfile *.sh call HeaderBash()

" -----------------------------------------------------------------------------
" format for specific file type
" -----------------------------------------------------------------------------

" PEP8 intent
au BufNewFile,BufRead *.py
    \ set tabstop=4       |
    \ set softtabstop=4   |
    \ set shiftwidth=4    |
    \ set expandtab       |
    \ set autoindent      |
    \ set fileformat=unix |
    \ set nowrap          |
    \ set sidescroll=5 
    " \ set listchars+=precedes:<,extends:>
    " \ set textwidth=79 |

au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2     |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" -----------------------------------------------------------------------------
" for Python coding
" -----------------------------------------------------------------------------

let python_highlight_all=1

" -----------------------------------------------------------------------------
" for ycm
" -----------------------------------------------------------------------------

let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_python_binary_path = 'python'
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1 
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_cache_omnifunc = 0

" for ycmd server, not completion
let g:ycm_server_python_interpreter = '/usr/bin/python'

" key mappings
nnoremap <leader>gt  :YcmCompleter GoTo<CR>
map      <leader>dd  :YcmCompleter GoToDefinitionElseDeclaration<CR>
map      <leader>rf  :YcmCompleter GoToReferences<CR>
map      <leader>doc :YcmCompleter GetDoc<CR>

" -----------------------------------------------------------------------------
" for NERDTree
" -----------------------------------------------------------------------------

" How can I map a specific key or shortcut to open NERDTree?
map <c-n> :NERDTreeToggle<CR>

" NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in = 1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" How can I close vim if the only window left open is a NERDTree?
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" hide specific files in NERDTREE
let g:NERDTreeIgnore=['\.pyc$', 
    \'\~$',
    \'__pycache__[[dir]]']

let NERDTreeNaturalSort=1 
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
" let NERDTreeMinimalUI=1

" -----------------------------------------------------------------------------
" other plugin config
" -----------------------------------------------------------------------------

" For Markdown-preview
" path to the chrome or the command to open chrome(or other modern browsers)
" if set, g:mkdp_browserfunc would be ignored
let g:mkdp_path_to_chrome = "/usr/bin/chromium"
" callback vim function to open browser, the only param is the url to open
let g:mkdp_browserfunc = 'MKDP_browserfunc_default'
" set to 1, the vim will open the preview window once enter the markdown buffer
let g:mkdp_auto_start = 0
" set to 1, the vim will auto open preview window when you edit the markdown file
let g:mkdp_auto_open = 0
" set to 1, the vim will auto close current preview window when change
" from markdown buffer to another buffer
let g:mkdp_auto_close = 1
" set to 1, the vim will just refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
let g:mkdp_refresh_slow = 0
" set to 1, the MarkdownPreview command can be use for all files,
" by default it just can be use in markdown file
let g:mkdp_command_for_global = 0
" nmap <silent> <F8> <Plug>MarkdownPreview        " for normal mode
" imap <silent> <F8> <Plug>MarkdownPreview        " for insert mode
" nmap <silent> <F9> <Plug>StopMarkdownPreview    " for normal mode
" imap <silent> <F9> <Plug>StopMarkdownPreview    " for insert mode

" For vim-airline
let g:airline_theme="minimalist"
let g:airline_powerline_fonts = 1
" let g:airline_theme="solarized"
" let g:airline_solarized_bg='dark'
" support for other plugins
let g:airline#extensions#tmuxline#enabled = 1

" For vim-autoformatter
let g:formatter_yapf_style = 'pep8'

" For vim-virtualenv
let g:virtualenv_directory = '~/Envs'

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
\ 'file': ['*.sw?','~$*','*.exe','*.o','*.so','*.py[co]']
\}
let g:Lf_MruFileExclude = ['*.so']
let g:Lf_UseVersionControlTool = 0 " use version control tool to index the files
" let g:Lf_PreviewCode = 0

" for FlyGrep
nnoremap <leader>s :FlyGrep<cr>

" for Flake8
" to use colors defined in the colorscheme
highlight link Flake8_Error      Error
highlight link Flake8_Warning    WarningMsg
highlight link Flake8_Complexity WarningMsg
highlight link Flake8_Naming     WarningMsg
highlight link Flake8_PyFlake    WarningMsg
" to run the Flake8 check every time you write
autocmd BufWritePost *.py call Flake8()

" for vim-slash 
noremap <plug>(slash-after) zz

" for vim-smooth-scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" for tagbar
noremap <leader>t :TagbarOpenAutoClose<CR>
" noremap <Leader>y :TagbarToggle<CR>        " Display panel with (,y)
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 1

" for devicons
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:WebDevIconsOS = 'ArchLinux'

" for startify
function! StartifyEntryFormat()
  return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

" for vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" for vim-emoji
set completefunc=emoji#complete

" for echodoc.vim
let g:echodoc_enable_at_startup = 1
let g:echodoc#enable_force_overwrite = 1

" for easymotion
" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" for Pydiction
let g:pydiction_location='~/.vim/plugged/pydiction/complete-dict'
let g:pydiction_menu_height=10

" for ultisnips
let g:UltiSnipsExpandTrigger="<c-space>"
let g:UltiSnipsListSnippets="<F9>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsUsePythonVersion = 3

" for colorscheme
noremap <leader>c :NextColorScheme<cr>:colorscheme<cr>
noremap <leader>C :PreviousColorScheme<cr>:colorscheme<cr>

" for solarized color
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1


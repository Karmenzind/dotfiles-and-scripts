" Github: https://github.com/Karmenzind/dotfiles-and-scripts

set nocompatible
set encoding=utf-8
set guifont=Monaco\ Nerd\ Font\ 12

" file type detection
filetype off 

" -----------------------------------------------------------------------------
"  Plugins Manage
" -----------------------------------------------------------------------------

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'morhetz/gruvbox'

Plugin 'Valloric/YouCompleteMe'
Plugin 'SirVer/ultisnips' " ultimate solution for snippets
Plugin 'Chiel92/vim-autoformat'

Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'wsdjeg/FlyGrep.vim'
Plugin 'Yggdroot/LeaderF'

Plugin 'tmhedberg/SimpylFold' " code folding for Python
Plugin 'nvie/vim-flake8' " Python syntax checker (flake8 required) [press F7 to run]
Plugin 'vim-scripts/indentpython.vim'
Plugin 'plytophogy/vim-virtualenv' " Python v e

Plugin 'terryma/vim-smooth-scroll' 
Plugin 'junegunn/goyo.vim'
Plugin 'junegunn/vim-slash'
Plugin 'mhinz/vim-startify'
Plugin 'majutsushi/tagbar'
Plugin 'iamcco/mathjax-support-for-mkdp'
Plugin 'iamcco/markdown-preview.vim'

" load after other plugins 
Plugin 'ryanoasis/vim-devicons'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'

" /* Alternative */
" Plugin 'chxuan/change-colorscheme'
" Plugin 'junegunn/limelight.vim'
" Plugin 'junegunn/rainbow_parentheses.vim'
" Plugin 'davidhalter/jedi-vim'
" Plugin 'vim-scripts/fcitx.vim' " keep and restore fcitx state when leaving/re-entering insert mode
" Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}  a status bar
" Plugin 'rkulla/pydiction' " Python Tab-completion 
" Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'kien/ctrlp.vim'  " search file inside vim
" https://github.com/python-mode/python-mode
" Plugin 'mhinz/vim-signify' 
" Plugin 'airblade/vim-gitgutter'


" All of your Plugins must be added before the following line
call vundle#end()            

" -----------------------------------------------------------------------------
" Basic
" -----------------------------------------------------------------------------

filetype plugin indent on    

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

" -----------------------------------------------------------------------------
"  coding
" -----------------------------------------------------------------------------

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
if version >= 700
   set spl=en spell
   set nospell
endif

" -----------------------------------------------------------------------------
"  File
" -----------------------------------------------------------------------------

" backup
"set backup
"set backupdir=~/tmp/vim_backup/
"set directory=~/.vim/tmp

set splitbelow
set splitright

" -----------------------------------------------------------------------------
" format for specific file type
" -----------------------------------------------------------------------------

" PEP8 intent
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ set nowrap | 
    \ set sidescroll=5 
    " \ set listchars+=precedes:<,extends:>
    " \ set textwidth=79 |

au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" -----------------------------------------------------------------------------
" for Python
" -----------------------------------------------------------------------------

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

" -----------------------------------------------------------------------------
" for ycm
" -----------------------------------------------------------------------------

let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_python_binary_path = 'python'
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

" for ycmd server, not completion
let g:ycm_server_python_interpreter = '/usr/bin/python2'
" let g:ycm_goto_buffer_command = 'horizontal-split'

" key mappings
nnoremap <leader>gt :YcmCompleter GoTo<CR>'
map <leader>dd  :YcmCompleter GoToDefinitionElseDeclaration<CR>
map <leader>rf  :YcmCompleter GoToReferences<CR>
map <leader>doc  :YcmCompleter GetDoc<CR>

" -----------------------------------------------------------------------------
" for NERDTree
" -----------------------------------------------------------------------------

" How can I map a specific key or shortcut to open NERDTree?
map <C-n> :NERDTreeToggle<CR>

" change default arrows?
" let g:NERDTreeDirArrowExpandable = '▸'
" let g:NERDTreeDirArrowCollapsible = '▾'

" NERDTree automatically when vim starts up
" autocmd vimenter * NERDTree

" open a NERDTree automatically when vim starts up if no files were specified
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

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
" set to 1, the vim will open the preview window once enter the markdown
" buffer
let g:mkdp_auto_start = 0
" set to 1, the vim will auto open preview window when you edit the
" markdown file
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

" for 'junegunn/rainbow_parentheses.vim'
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" for tagbar
noremap <leader>t :TagbarOpenAutoClose<CR>
" let g:tagbar_ctags_bin='/usr/bin/ctags'    " Proper Ctags locations
" let g:tagbar_width=26                      " Default is 40, seems too wide
" noremap <Leader>y :TagbarToggle<CR>        " Display panel with (,y)
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 1

" for change-colorscheme
" nnoremap <leader>nc :NextColorScheme<cr>
" map <F10> :NextColorScheme<CR>
" imap <F10> <ESC> :NextColorScheme<CR>
" map <F9> :PreviousColorScheme<CR>
" imap <F9> <ESC> :PreviousColorScheme<CR>

" for devicons
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:WebDevIconsOS = 'ArchLinux'

let entry_format = "'   ['. index .']'. repeat(' ', (3 - strlen(index)))"
if exists('*WebDevIconsGetFileTypeSymbol')  " support for vim-devicons
    let entry_format .= ". WebDevIconsGetFileTypeSymbol(entry_path) .' '.  entry_path"
else 
    let entry_format .= '. entry_path'
endif

" -----------------------------------------------------------------------------
" /* reference */
" -----------------------------------------------------------------------------

" https://stackoverflow.com/questions/164847/what-is-in-your-vimrc
" https://segmentfault.com/a/1190000003962806

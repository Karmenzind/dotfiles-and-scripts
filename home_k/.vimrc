" Github: https://github.com/Karmenzind/dotfiles-and-scripts

" --------------------------------------------
" general keymaps and abbreviations
" --------------------------------------------

noremap <Leader>e  :tabe   $MYVIMRC<CR>
noremap <Leader>R  :source $MYVIMRC<CR> :echom 'Vimrc reloaded :)'<CR>
noremap <Leader>S  :source %<CR> :echom expand('%') . ' sourced :)'<CR>

" /* command */
cabbrev w!! w !sudo tee %
cabbrev th tab<SPACE>help

" /* workspace, layout, format and others */
nnoremap <silent> <A-a> gT
nnoremap <silent> <A-d> gt
" use <Leader>s as 'set' prefix
nnoremap <silent> <Leader>sw :set wrap!<CR> :set wrap?<CR>
nnoremap <silent> <Leader>sb :call BackgroudToggle()<CR>
nnoremap <silent> <leader>q  :call QuickfixToggle()<CR>

" /* input */
" inoremap <c-d> <delete>
nnoremap <leader><CR> i<CR><ESC>k$

" --------------------------------------------
"  plugin manager
" --------------------------------------------

" /* automatically install Plug */
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !mkdir -p ~/.vim/autoload &&
        \ wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        \ -O ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'junegunn/vim-plug'

" /* coding tools */
Plug 'tpope/vim-endwise'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Shougo/context_filetype.vim'
Plug 'majutsushi/tagbar'
Plug 'Shougo/echodoc.vim'
Plug 'w0rp/ale' " Asynchronous Lint Engine
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang --go-completer --js-completer --java-completer' }
" Plug 'terryma/vim-multiple-cursors'
" Plug 'junegunn/rainbow_parentheses.vim'
" Plug 'Valloric/MatchTagAlways'

" /* version control | workspace */
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 't9md/vim-choosewin'
Plug 'mhinz/vim-startify'
" Plug 'junegunn/gv.vim'
" Plug 'bagrat/vim-workspace' " tab bar

" /* Search */
Plug 'mileszs/ack.vim'
Plug 'Yggdroot/LeaderF'
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/vim-slash' " enhancing in-buffer search experience
" Plug 'junegunn/fzf' | Plug 'junegunn/fzf.vim'
" Plug 'junegunn/fzf', {'dir': '~/.local/fzf', 'do': './install --all'}
" Plug 'haya14busa/vim-signjk-motion'

" /* Python */
Plug 'tmhedberg/SimpylFold', { 'for': 'python' } " code folding
Plug 'vim-scripts/indentpython.vim', { 'for': 'python' }
" Plug 'plytophogy/vim-virtualenv', { 'for': 'python' }
" Plug 'python-mode/python-mode', { 'for': 'python' }

" /* Write doc */
Plug 'godlygeek/tabular'
Plug 'mzlogin/vim-markdown-toc', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.vim', { 'for': 'markdown' }
Plug 'nelstrom/vim-markdown-folding', { 'for': 'markdown' }
Plug 'mklabs/vim-markdown-helpfile'
Plug 'Traap/vim-helptags'
" Plug 'iamcco/mathjax-support-for-mkdp', { 'for': 'markdown' }  " before markdown-preview
" Plug 'scrooloose/vim-slumlord'

" /* Experience */
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'vim-scripts/fcitx.vim', {'for': 'markdown'} " keep and restore fcitx state when leaving/re-entering insert mode
" Plug 'junegunn/limelight.vim'
" Plug 'terryma/vim-smooth-scroll'

" /* Mine */
Plug 'karmenzind/vim-tmuxlike'

" /* Funny Stuff */
Plug 'junegunn/vim-emoji', { 'for': 'markdown,gitcommit' }
" Plug 'vim-scripts/TeTrIs.vim'

" /* Syntax | Fold */
" Plug 'demophoon/bash-fold-expr', { 'for': 'sh' }
" Plug 'vim-scripts/txt.vim', { 'for': 'txt' }

" /* Appearance */
Plug 'flazz/vim-colorschemes'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons' " load after other plugins
Plug 'gerardbm/vim-atomic'
Plug 'icymind/NeoSolarized'
" Plug 'chxuan/change-colorscheme', { 'on': 'NextColorScheme' }

call plug#end()

" --------------------------------------------
" basic
" --------------------------------------------

" /* base */
" runtime macros/matchit.vim
set nocompatible
set noerrorbells
set showcmd " This shows what you are typing as a command.
set noincsearch
" set report=0
" set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg

" /* appearence */
set wildmenu
set ruler
set showtabline=1
set guifont=Hack\ Nerd\ Font\ 12
set cursorline
set showmode
set cmdheight=2
set laststatus=2
set matchtime=5
" highlight CursorLine guibg=darkgray ctermbg=black
" set noshowmode
" set whichwrap+=<,>,h,l
" set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]
set statusline=%f\ %{WebDevIconsGetFileTypeSymbol()}\ %h%w%m%r\ %=%(%l,%c%V\ %Y\ %=\ %P%)
" cursor's shape (FIXIT)
" let &t_SI = "\e[6 q"
" let &t_EI = "\e[2 q"

" /* line number */
set number
augroup relative_number_toggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

" /* layout */
set splitbelow splitright

" /* operate and edit */
set mouse=a
set backspace=indent,eol,start  " more powerful backspacing
" make * reg the default
if has('clipboard')
  set clipboard=unnamed
endif
if has('gui_running')
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif
set scrolloff=5

" /* Enable folding */
" set foldlevel=99

" /* spell check */
set spelllang=en nospell

" /* cache and swap */
set history=50
set nobackup
" set noswapfile
" set autoread
" set autowrite
" set confirm
" Move the swap file location to protect against CVE-2017-1000382
" if exists('$XDG_CACHE_HOME')
" 	let &g:directory=$XDG_CACHE_HOME
" else
" 	let &g:directory=$HOME . '/.cache'
" endif
" let &g:directory.='/vim/swap//'
" " Create swap directory if it doesn't exist
" if ! isdirectory(expand(&g:directory))
"   silent! call mkdir(expand(&g:directory), 'p', 0700)
" endif

" /* persistent undo */
" set undodir=~/.vim/persistence/undo//
" set backupdir=~/.vim/persistence/backup//
" set directory=~/.vim/persistence/swp//
" set undofile

" --------------------------------------------
" format and syntax
" --------------------------------------------

syntax enable
" syntax on
" filetype plugin indent on

set termencoding=utf-8
set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030
set encoding=utf-8

set iskeyword+=_,$,@,%,#,-
set fileformat=unix

" for different file types
augroup filetype_formats
  au!
  au FileType *
        \ setlocal shiftwidth=4      |
        \ setlocal expandtab         |
        \ setlocal smarttab          |
        \ setlocal tabstop=4         |
        \ setlocal softtabstop=4

  au FileType help setlocal nu

  au BufNewFile,BufRead *.{vim,vimrc}
        \ setlocal tabstop=2         |
        \ setlocal softtabstop=2     |
        \ setlocal shiftwidth=2      |
        \ setlocal foldmethod=expr   |
        \ setlocal foldlevel=2       |
        \ setlocal foldexpr=VimScriptFold(v:lnum)

  au BufNewFile,BufRead *.py
        \ setlocal autoindent            |
        \ setlocal nowrap                |
        \ setlocal sidescroll=5          |
        \ let b:python_highlight_all = 1 |
        \ setlocal complete+=t           |
        \ setlocal formatoptions-=t      |
        \ setlocal nowrap                |
        \ setlocal commentstring=#%s     |
        \ setlocal define=^\s*\\(def\\\\|class\\)
  " \ set listchars+=precedes:<,extends:>
  " \ set textwidth=79 |

  au BufNewFile,BufRead *.js,*.html,*.css,*.yml
        \ setlocal tabstop=2     |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2

  " autocmd BufNewFile,BufRead *.{md,mkd,mkdn,mark*}
  "   \ set filetype=markdown

  " useless whitespaces
  au BufRead,BufNewFile *.py,*.pyw,*.c,*.h,*.{vim,vimrc}
        \ highlight BadWhitespace ctermbg=red guibg=darkred |
        \ match BadWhitespace /\s\+$/

augroup END

" --------------------------------------------
" Header
" --------------------------------------------

" /* file headers */
augroup add_file_headers
  au!
  au BufNewFile *.sh
        \ call setline(1, '#!/usr/bin/env bash')                   |
        \ call append(line('.'), '')                               |
        \ normal! Go
  au BufNewFile *.py
        \ call setline(1, '#!/usr/bin/env python')                 |
        \ call append(line('.'), '# -*- coding: utf-8 -*-')        |
        \ call append(line('.')+1, '')                             |
        \ normal! Go
  au BufNewFile *.{cpp,cc}
        \ call setline(1, '#include <iostream>')                   |
        \ call append(line('.'), '')                               |
        \ normal! Go
  au BufNewFile *.c
        \ call setline(1, '#include <stdio.h>')                    |
        \ call append(line('.'), '')                               |
        \ normal! Go
  au BufNewFile *.h,*.hpp
        \ call setline(1, '#ifndef _'.toupper(expand('%:r')).'_H') |
        \ call setline(2, '#define _'.toupper(expand('%:r')).'_H') |
        \ call setline(3, '#endif')                                |
        \ normal! Go
augroup END

" --------------------------------------------
" plugin configuration
" --------------------------------------------

" /* for YCM */
if empty(glob('~/.vim/.ycm_extra_conf.py'))
  silent !wget https://raw.githubusercontent.com/Karmenzind/dotfiles-and-scripts/master/home_k/.vim/.ycm_extra_conf.py
        \ -O ~/.vim/.ycm_extra_conf.py
endif

let g:ycm_filetype_blacklist = {
      \ 'gitcommit': 1,
      \ 'tagbar' : 1,
      \ 'qf' : 1,
      \ 'notes' : 1,
      \ 'unite' : 1,
      \ 'text' : 1,
      \ 'vimwiki' : 1,
      \ 'pandoc' : 1,
      \ 'infolog' : 1,
      \ 'mail' : 1,
      \}

set completeopt-=preview
set completeopt+=longest,menu
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_autoclose_preview_window_after_completion = 1

let g:ycm_max_num_candidates = 14
let g:ycm_max_num_identifier_candidates = 7
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_server_python_interpreter = '/usr/bin/python3'
let g:ycm_python_binary_path = 'python3'
let g:ycm_goto_buffer_command = 'horizontal-split'

let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_collect_identifiers_from_tags_files = 1
" let g:ycm_collect_identifiers_from_comments_and_strings = 1

nnoremap <silent> <Leader>gt  :YcmCompleter GoTo<CR>
nnoremap <silent> <Leader>dd  :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <silent> <Leader>rf  :YcmCompleter GoToReferences<CR>
nnoremap <silent> <Leader>doc :YcmCompleter GetDoc<CR>

augroup ycm_autos
  au!
  au FileType python
        \ nnoremap <silent> <C-]> :YcmCompleter GoTo<CR>
augroup END

" /* for NERDTree */
nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
let g:NERDTreeIgnore = ['\.pyc$', '\~$', '__pycache__[[dir]]']

augroup nerd_behaviours
  au!
  autocmd StdinReadPre * let s:std_in = 1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd tableave * if exists('g:loaded_nerd_tree') | execute 'NERDTreeClose' | endif
augroup END

let g:NERDTreeNaturalSort = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeShowHidden = 1

" /* For vim-airline */
nnoremap <Leader>A :AirlineToggle<CR>:AirlineRefresh<CR>
let g:airline_powerline_fonts = 1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_mode_map = {
      \ '__' : '-',
      \ 'n'  : 'N',
      \ 'i'  : 'I',
      \ 'R'  : 'R',
      \ 'c'  : 'C',
      \ 'v'  : 'V',
      \ 'V'  : 'V',
      \ '' : 'V',
      \ 's'  : 'S',
      \ 'S'  : 'S',
      \ '' : 'S',
      \ 't'  : 'T',
      \ }
let g:airline_highlighting_cache = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#ale#enabled = 0
let g:airline#extensions#branch#enabled = 0
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#fugitiveline#enabled = 0
let g:airline#extensions#hunks#enabled = 0
" let g:airline#extensions#hunks#non_zero_only = 1

" /* for LeaderF */
" let g:Lf_ShortcurF = '<Leader>n'
nnoremap <Leader>ff :LeaderfFile<CR>
highlight Lf_hl_match gui=bold guifg=Blue cterm=bold ctermfg=21
highlight Lf_hl_matchRefine  gui=bold guifg=Magenta cterm=bold ctermfg=201
let g:Lf_WindowPosition = 'bottom'
let g:Lf_DefaultMode = 'FullPath'
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_ShowHidden = 1
let g:Lf_WildIgnore = {
      \  'dir': ['.svn', '.git', '.hg', '.idea', '__pycache__', '.scrapy'],
      \  'file': ['*.sw?', '~$*', '*.exe', '*.o', '*.so', '*.py[co]'] }
let g:Lf_MruFileExclude = ['*.so']
let g:Lf_UseVersionControlTool = 0

" /* for Ack */
nnoremap <Leader>fc :Ack!<space>
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
let g:ackhighlight = 1
let g:ack_mappings = {
      \  'v':  '<C-W><CR><C-W>L<C-W>p<C-W>J<C-W>p',
      \  'gv': '<C-W><CR><C-W>L<C-W>p<C-W>J' }

" /* for tagbar */
noremap <Leader>t :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 1

" /* for devicons */
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
" let g:WebDevIconsOS = 'ArchLinux'

" /* for startify */
function! StartifyEntryFormat()
  return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

" /* for vim-easy-align */
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" /* for vim-emoji */
set completefunc=emoji#complete

" /* for echodoc.vim */
let g:echodoc_enable_at_startup = 1
let g:echodoc#enable_force_overwrite = 1

" /* for easymotion */
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" /* for ultisnips */
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsListSnippets = '<F9>'
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsSnippetsDir = $HOME . '/.vim/mysnippets'
let g:UltiSnipsSnippetDirectories=['UltiSnips', 'mysnippets']
let g:UltiSnipsEnableSnipMate = 1
let g:snips_author = 'k'
let g:snips_email = 'valesail7@gmail.com'
let g:snips_github = 'https://github.com/Karmenzind/'

" /* for ale */
nmap <silent> <C-k> <Plug>(ale_previous)
nmap <silent> <C-j> <Plug>(ale_next)
nmap <silent> <Leader>fix <Plug>(ale_fix)
let g:ale_linters = {
      \  'vim': ['vint'],
      \  'markdown': ['mdl', 'prettier', 'proselint', 'alex'],
      \  'text': ['proselint', 'alex', 'redpen'],
      \  'gitcommit': ['gitlint'],
      \  'dockerfile': ['hadolint'],
      \  'sql': ['sqlint'],
      \  'cpp': ['gcc'],
      \ }
let g:ale_fixers = {
      \  '*': ['trim_whitespace'],
      \  'c': ['clang-format'],
      \  'sh': ['shfmt'],
      \  'python': [
      \    'autopep8',
      \    'isort',
      \  ],
      \ }

" /* for vim-multiple-cursors */
" if !has('gui_running')
"   map <M-n> <A-n>
" endif

" /* for vim-markdown | markdown-preview */
" vim-markdown
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_json_frontmatter = 1

" markdown-preview
let g:mkdp_path_to_chrome = '/usr/bin/chromium'
let g:mkdp_browserfunc = 'MKDP_browserfunc_default'
let g:mkdp_auto_start = 0
let g:mkdp_auto_open = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0

" particular keymaps
augroup for_markdown_ft
  au!
  au FileType markdown
        \ nnoremap <silent> <Leader>mt :Toc<CR>             |
        \ nnoremap <silent> <Leader>mp :MarkdownPreview<CR>
augroup END

" /* for SimpylFold */
let g:SimpylFold_docstring_preview = 1
let g:SimpylFold_fold_docstring = 0

" /* for choosewin */
" invoke with '-'
" nmap  -  <Plug>(choosewin)
" " if you want to use overlay feature
" let g:choosewin_overlay_enable = 1

" /* for vim-tmuxlike */
nmap <silent> <c-\> <Plug>(tmuxlike-prefix)

" /* for vim-plug */
noremap <Leader>pi :PlugInstall<CR>
noremap <Leader>pu :PlugUpdate<CR>
noremap <Leader>ps :PlugStatus<CR>
noremap <Leader>pc :PlugClean<CR>

" /* for startify */
let g:startify_update_oldfiles = 1
let g:startify_change_to_dir = 0
let g:startify_session_persistence = 1
let g:startify_session_before_save = [ 'silent! NERDTreeClose' ]

augroup staritify_autos
  au!
  autocmd VimEnter * let t:startify_new_tab = 1
  autocmd BufEnter *
        \ if !exists('t:startify_new_tab') && empty(expand('%')) |
        \   let t:startify_new_tab = 1 | Startify | endif
augroup END

function! s:list_commits()
  let l:not_repo = str2nr(system("git rev-parse >/dev/null 2>&1; echo $?"))
  if l:not_repo | return | endif
  let list_cmd = 'git log --oneline | head -n7'
  if executable('emojify') | let list_cmd .= ' | emojify' | endif
  let commits = systemlist(list_cmd)
  return map(commits, '{"line": matchstr(v:val, "\\s\\zs.*"), "cmd": "Git show ". matchstr(v:val, "^\\x\\+") }')
  return map(commits, '{"line": {matchstr(v:val, "^\\x\\+"): matchstr(v:val, "\\s\\zs.*")}, "cmd": "Git show ". matchstr(v:val, "^\\x\\+") }')
endfunction

let g:startify_lists = [
      \ { 'header': ['   » SESSIONS    '], 'type': 'sessions' },
      \ { 'header': ['   » RECENT FILES'],   'type': 'files' },
      \ { 'header': ['   » GIT HISTORY '],  'type': function('s:list_commits') },
      \ ]

" --------------------------------------------
" Functions
" --------------------------------------------

" toggle quickfix window
let g:quickfix_is_open = 0
function! QuickfixToggle()
  if g:quickfix_is_open
    cclose
    let g:quickfix_is_open = 0
    execute g:quickfix_return_to_window . "wincmd w"
  else
    let g:quickfix_return_to_window = winnr()
    copen
    let g:quickfix_is_open = 1
  endif
endfunction

" (toggle) set termguicolors
function! SetTermguiColors(k)
  if a:k ==# 'yes'
    if &termguicolors == 0 && has('termguicolors')
      set termguicolors
    endif
  elseif &termguicolors == 1
    set notermguicolors
  endif
endfunction

" toggle background
function! BackgroudToggle()
  if &background ==# 'dark'
    set background=light
  elseif &background ==# 'light'
    set background=dark
  endif
endfunction

" let background fit the clock
function! LetBgFitClock()
  let b:current_hour = strftime('%H')
  if b:current_hour >=8 && b:current_hour <= 16
    set background=light
  else
    set background=dark
  endif
endfunction

" try to set termguicolors and return the status
function! InitTermguicolors()
  if &termguicolors == 0 && has('termguicolors')
    set termguicolors
  endif
  return &termguicolors
endfunction

" initialize the colorscheme
function! InitColors()
  " gruvbox bubblegum birds-of-paradise blaquemagick buddy_modified dante
  " eclipse darkburn enigma eva01 evening evolution apprentice
  if $USER == 'k'
    if has('nvim')
      colorscheme solarized
    else
      if InitTermguicolors()
        colorscheme atomic
      else
        colorscheme evening
      endif
    endif
    call AfterChangeColorscheme()
  else
    colorscheme molokai
  endif
endfunction

" do some highlights after set colo
function! AfterChangeColorscheme()
  call LetBgFitClock()
  if !(exists('$TMUX') && $TERM !~ '\vtmux|italic')
    highlight Comment cterm=italic
  endif
endfunction

" vim's folding expr
function! VimScriptFold(lnum)
  if getline(a:lnum) =~? '\v^\s*$'
    return '-1'
  elseif getline(a:lnum) =~? '\v^"\s+(-{44}|\/\*).*$'
    return '0'
  elseif getline(a:lnum) =~? '\v^\s*".*$'
    if a:lnum > 0 && (getline(a:lnum + 1) =~? '\v^\s*(".*)?$' || getline(a:lnum - 1) =~? '\v^\s*"')
      return '3'
    else
      return '1'
    endif
  elseif getline(a:lnum) =~? '\v^(augroup|function).*$'
    return '1'
  elseif getline(a:lnum) =~? '\v\S'
    return '2'
  endif
endfunction

" au when change colo
augroup fit_colorscheme
  au!
  if v:version >= 801
    au ColorSchemePre * call SetTermguiColors('no')
    au ColorSchemePre atomic,NeoSolarized,ayu,palenight
          \ call SetTermguiColors('yes')
  endif
  au ColorScheme * call AfterChangeColorscheme()
augroup END

" --------------------------------------------
" colorscheme
" --------------------------------------------

" /* for solarized */
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1

" /* for vim-atomic */
let g:atomic_mode = 3
let g:atomic_italic = 1
let g:atomic_bold = 1
let g:atomic_underline = 1
let g:atomic_undercurl = 1
nnoremap <Leader>cm :call CycleModes()<CR>:colorscheme atomic<CR>
vnoremap <Leader>cm :<C-u>call CycleModes()<CR>:colorscheme atomic<CR>gv

" /* initial */
set background=dark

" italic
set t_ZH=[3m
set t_ZR=[23m

" enhance termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" initialize the colo
call InitColors()

" --------------------------------------------
" extra
" --------------------------------------------

" load local configure
let s:extra_vimrc = glob('~/.vimrc.local')
if filereadable(s:extra_vimrc)
  execute 'source' . s:extra_vimrc
endif


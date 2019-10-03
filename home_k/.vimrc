" Github: https://github.com/Karmenzind/dotfiles-and-scripts

" --------------------------------------------
" general keymaps and abbreviations
" --------------------------------------------

noremap <Leader>e  :call EditRcFiles()<CR>
noremap <Leader>R  :source $MYVIMRC<CR> :echom 'Vimrc reloaded :)'<CR>
noremap <Leader>S  :source %<CR> :echom expand('%') . ' sourced :)'<CR>
noremap <Leader>T  :terminal<CR>

" /* command */
cabbrev w!! w !sudo tee %
cabbrev th tab<SPACE>help
cabbrev sss s/\v(,)\s*/\1\r/g

" /* workspace, layout, format and others */
nnoremap <silent> <A-a> gT
nnoremap <silent> <A-d> gt

" use <Leader>s as 'set' prefix
nnoremap <silent> <Leader>sw :set wrap!<CR> :set wrap?<CR>
nnoremap <silent> <Leader>sb :call BackgroudToggle()<CR>
nnoremap <silent> <leader>q  :call QuickfixToggle()<CR>

" /* input */
inoremap <c-d> <delete>
nnoremap <leader><CR> i<CR><ESC>k$

" --------------------------------------------
"  plugin manager
" --------------------------------------------

" /* automatically install Plug */
if empty(glob('~/.vim/autoload/plug.vim')) && !has('win32')
  silent !mkdir -p ~/.vim/autoload &&
        \ wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        \ -O ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.force
     !./install.py --clang-completer --clangd-completer --system-libclang --go-completer --js-completer --java-completer
  endif
endfunction


call plug#begin()
Plug 'junegunn/vim-plug'

" /* coding tools */
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Shougo/context_filetype.vim'
Plug 'majutsushi/tagbar'
Plug 'Shougo/echodoc.vim'
Plug 'w0rp/ale' " Asynchronous Lint Engine
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'terryma/vim-multiple-cursors'
" Plug 'zxqfl/tabnine-vim'
" Plug 'tenfyzhong/CompleteParameter.vim'
" Plug 'junegunn/rainbow_parentheses.vim'
" Plug 'Valloric/MatchTagAlways'

" /* version control | workspace */
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 't9md/vim-choosewin'
Plug 'mhinz/vim-startify'
if executable('svn')
  Plug 'juneedahamed/vc.vim'
endif
" Plug 'junegunn/gv.vim'
" Plug 'bagrat/vim-workspace' " tab bar

" /* Search */
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/vim-slash' " enhancing in-buffer search experience
if executable('fzf')
  Plug 'junegunn/fzf'
else
  Plug 'junegunn/fzf', {'dir': '~/.local/fzf', 'do': './install --all'}
endif
Plug 'junegunn/fzf.vim'
" Plug 'mileszs/ack.vim'
" Plug 'Yggdroot/LeaderF'
" Plug 'haya14busa/vim-signjk-motion'

" /* Python */
Plug 'tmhedberg/SimpylFold' " code folding
Plug 'vim-scripts/indentpython.vim'
Plug 'tweekmonster/django-plus.vim'
" Plug 'plytophogy/vim-virtualenv'
" Plug 'python-mode/python-mode'

" /* Write doc */
Plug 'godlygeek/tabular'
Plug 'mzlogin/vim-markdown-toc'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'nelstrom/vim-markdown-folding'
Plug 'mklabs/vim-markdown-helpfile'
Plug 'Traap/vim-helptags'
" Plug 'iamcco/mathjax-support-for-mkdp'  " before markdown-preview
" Plug 'scrooloose/vim-slumlord'

" /* Experience | Enhancement */
if !has('clipboard') | Plug 'kana/vim-fakeclip' | endif
if executable('fcitx') | Plug 'vim-scripts/fcitx.vim' | endif
Plug 'junegunn/goyo.vim'
" Plug 'junegunn/limelight.vim'
" Plug 'terryma/vim-smooth-scroll'

" /* Funny Stuff */
Plug 'junegunn/vim-emoji', { 'for': 'markdown,gitcommit' }
" Plug 'vim-scripts/TeTrIs.vim'

" /* Syntax | Fold */
Plug 'cespare/vim-toml'
" Plug 'demophoon/bash-fold-expr', { 'for': 'sh' }
" Plug 'vim-scripts/txt.vim', { 'for': 'txt' }

" /* Enhancement */
Plug 'karmenzind/vim-tmuxlike'

" /* Appearance */
Plug 'flazz/vim-colorschemes'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'gerardbm/vim-atomic'
Plug 'icymind/NeoSolarized'
Plug 'junegunn/seoul256.vim'
Plug 'ryanoasis/vim-devicons' " load after other plugins
" Plug 'chxuan/change-colorscheme', { 'on': 'NextColorScheme' }

call plug#end()

" internal plugins
runtime macros/matchit.vim
runtime! ftplugin/man.vim

" --------------------------------------------
" basic
" --------------------------------------------

" /* base */
set nocompatible
set noerrorbells
set showcmd " This shows what you are typing as a command.
set noincsearch
set ttimeoutlen=0
" set report=0
" set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg

" /* appearence */
set wildmenu
set ruler
set showtabline=1
if has('win32')
  set guifont=consolas:h13
else
  set guifont=Hack\ Nerd\ Font\ 12
endif
set cursorline
set showmode
set cmdheight=2
set laststatus=2
set matchtime=5
set nowrap

" set noshowmode
" set whichwrap+=<,>,h,l
" set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]
" set statusline=%f\ %{WebDevIconsGetFileTypeSymbol()}\ %h%w%m%r\ %=%(%l,%c%V\ %Y\ %=\ %P%)
function! EchoIfNotUnix()
  if &ff ==? 'unix'
    return ''
  endif
  return '<' . &ff . '>'
endfunction
set statusline=%f\ %h%w%m%r\ %=%(%l,%c%V\ %{WebDevIconsGetFileTypeSymbol()}\ %{EchoIfNotUnix()}\%=\ %P%)
" cursor's shape (FIXIT)
if !has('nvim')
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
endif

" /* line number */
set number
augroup relative_number_toggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu | else | set nu rnu | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | else | set nu rnu | endif
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
set foldlevel=99

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

  au BufNewFile,BufRead *.{vim},*vimrc
        \ setlocal tabstop=2         |
        \ setlocal softtabstop=2     |
        \ setlocal shiftwidth=2      |
        \ setlocal foldmethod=expr   |
        \ setlocal foldlevel=2       |
        \ setlocal foldexpr=VimScriptFold(v:lnum)

  au BufNewFile,BufRead *.py
        \ setlocal autoindent            |
        \ setlocal sidescroll=5          |
        \ let b:python_highlight_all = 1 |
        \ setlocal complete+=t           |
        \ setlocal formatoptions-=t      |
        \ setlocal commentstring=#%s     |
        \ setlocal define=^\s*\\(def\\\\|class\\)
  " \ set listchars+=precedes:<,extends:>
  " \ set textwidth=79 |

  au BufNewFile,BufRead *.js,*.html,*.css,*.yml,*.toml
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
if empty(glob('~/.vim/.ycm_extra_conf.py')) && !has('win32')
  silent !wget https://raw.githubusercontent.com/Karmenzind/dotfiles-and-scripts/master/home_k/.vim/.ycm_extra_conf.py
        \ -O ~/.vim/.ycm_extra_conf.py
endif

let g:ycm_filetype_blacklist = {
      \ 'gitcommit': 1,
      \ 'tagbar': 1,
      \ 'qf': 1,
      \ 'notes': 1,
      \ 'unite': 1,
      \ 'text': 1,
      \ 'vimwiki': 1,
      \ 'pandoc': 1,
      \ 'infolog': 1,
      \ 'mail': 1,
      \ }

set completeopt-=preview
set completeopt+=longest,menu
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_autoclose_preview_window_after_completion = 1

let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_server_python_interpreter = '/usr/bin/python3'
let g:ycm_python_binary_path = 'python3'
let g:ycm_goto_buffer_command = 'horizontal-split'

let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_collect_identifiers_from_tags_files = 1
" let g:ycm_collect_identifiers_from_comments_and_strings = 1
" let g:ycm_max_num_candidates = 14
" let g:ycm_max_num_identifier_candidates = 7

let g:ycm_semantic_triggers = {
 \   'python': [ 're!(import\s+|from\s+(\w+\s+(import\s+(\w+,\s+)*)?)?)'  ]
 \ }

nnoremap <silent> <Leader>gt  :YcmCompleter GoTo<CR>
nnoremap <silent> <Leader>dd  :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <silent> <Leader>rf  :YcmCompleter GoToReferences<CR>
nnoremap <silent> <Leader>doc :YcmCompleter GetDoc<CR>

augroup ycm_autos
  au!
  au FileType python
        \ nnoremap <buffer> <silent> <C-]> :YcmCompleter GoTo<CR>
augroup END

" /* for NERDTree */
nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
let g:NERDTreeIgnore = ['\.pyc$', '\~$', '__pycache__[[dir]]']
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeNaturalSort = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeShowHidden = 1

augroup nerd_behaviours
  au!
  autocmd StdinReadPre * let s:std_in = 1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd tableave * if exists('g:loaded_nerd_tree') | execute 'NERDTreeClose' | endif
augroup END

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

" /* for fzf */
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit',
      \ 'ctrl-q': function('s:build_quickfix_list') }
let g:fzf_layout = { 'down': '~50%' }
let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags -R'
let g:fzf_history_dir = '~/.local/share/fzf-history'

command! -bang -nargs=* Ag
      \ call fzf#vim#ag(<q-args>,
      \                 <bang>0 ? fzf#vim#with_preview('up:60%')
      \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
      \                 <bang>0)

command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

nnoremap <Leader>ff :Files<CR>
nnoremap <Leader>fa :Ag<SPACE>
nnoremap <Leader>fr :Rg<SPACE>
nnoremap <Leader>fl :Lines<SPACE>
nnoremap <Leader>fL :BLines<SPACE>
nnoremap <Leader>fb :Buffers<CR>
nnoremap <Leader>fw :Windows<CR>
nnoremap <Leader>fs :Snippets<CR>
nnoremap <Leader>fh :History/<CR>

" /* for LeaderF */
" let g:Lf_ShortcurF = '<Leader>n'
" nnoremap <Leader>ff :LeaderfFile<CR>
" highlight Lf_hl_match gui=bold guifg=Blue cterm=bold ctermfg=21
" highlight Lf_hl_matchRefine  gui=bold guifg=Magenta cterm=bold ctermfg=201
" let g:Lf_WindowPosition = 'bottom'
" let g:Lf_DefaultMode = 'FullPath'
" let g:Lf_StlColorscheme = 'powerline'
" let g:Lf_ShowHidden = 1
" let g:Lf_WildIgnore = {
"       \  'dir': ['.svn', '.git', '.hg', '.idea', '__pycache__', '.scrapy'],
"       \  'file': ['*.sw?', '~$*', '*.exe', '*.o', '*.so', '*.py[co]'] }
" let g:Lf_MruFileExclude = ['*.so']
" let g:Lf_UseVersionControlTool = 0

" /* for Ack */
" nnoremap <Leader>fc :Ack!<space>
" if executable('ag')
"   let g:ackprg = 'ag --vimgrep'
" endif
" let g:ackhighlight = 1
" let g:ack_mappings = {
"       \  'v':  '<C-W><CR><C-W>L<C-W>p<C-W>J<C-W>p',
"       \  'gv': '<C-W><CR><C-W>L<C-W>p<C-W>J' }

" /* for tagbar */
noremap <Leader>t :call TToggle()<CR>
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 1
let g:tagbar_sort = 0

" /* for devicons */
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
" let g:WebDevIconsOS = 'ArchLinux'

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
cabbrev UE UltiSnipsEdit
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsListSnippets = '<F9>'
let g:UltiSnipsEditSplit = 'tabdo'
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsSnippetsDir = $HOME . '/.vim/mysnippets'
let g:UltiSnipsSnippetDirectories = ['UltiSnips', 'mysnippets']
let g:UltiSnipsEnableSnipMate = 1
let g:snips_author = 'k'
let g:snips_email = 'valesail7@gmail.com'
let g:snips_github = 'https://github.com/Karmenzind/'

" /* for ale */
nmap <silent> <C-k> <Plug>(ale_previous)
nmap <silent> <C-j> <Plug>(ale_next)
nmap <silent> <Leader>al <Plug>(ale_lint)
nmap <silent> <Leader>af <Plug>(ale_fix)
nmap <silent> <Leader>at <Plug>(ale_toggle)
cabbrev AF ALEFix

let g:ale_linters = {
      \  'vim': ['vint'],
      \  'markdown': ['mdl', 'prettier', 'proselint', 'alex'],
      \  'text': ['proselint', 'alex', 'redpen'],
      \  'javascript': ['prettier', 'importjs'],
      \  'gitcommit': ['gitlint'],
      \  'dockerfile': ['hadolint'],
      \  'sql': ['sqlint'],
      \  'cpp': ['gcc'],
      \ }
let g:ale_fixers = {
      \  '*': ['trim_whitespace'],
      \  'c': ['clang-format'],
      \  'javascript': ['prettier', 'importjs'],
      \  'sh': ['shfmt'],
      \  'python': ['autopep8', 'isort'],
      \  'json': ['fixjson', 'prettier'],
      \ }

let g:ale_warn_about_trailing_whitespace = 0
let g:ale_maximum_file_size = 1024 * 1024
let g:ale_set_balloons_legacy_echo = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" for python
let g:ale_python_mypy_ignore_invalid_syntax = 1
let g:ale_python_mypy_options = '--incremental'
let g:ale_python_pylint_options = '--max-line-length=120'
let g:ale_python_autopep8_options = '--max-line-length=120'
let g:ale_python_flake8_options = '--max-line-length=120'

" format
let g:ale_echo_msg_format = '(%severity% %linter%) %code:% %s'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_info_str = 'I'
let g:ale_echo_msg_warning_str = 'W'

" others
let g:ale_c_parse_compile_commands = 1
let g:ale_typescript_tslint_ignore_empty_files = 1

" /* for vim-multiple-cursors */
if !has('gui_running')
  map <M-n> <A-n>
endif

" /* for vim-markdown | markdown-preview */
" vim-markdown
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_json_frontmatter = 1

" markdown-preview
let g:mkdp_path_to_chrome = system("which chromium")
" let g:mkdp_browserfunc = 'MKDP_browserfunc_default'
let g:mkdp_open_to_the_world = 0
let g:mkdp_open_ip = ''

let g:mkdp_auto_start = 0
let g:mkdp_auto_open = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0
let g:mkdp_echo_preview_url = 1
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle'
    \ }


" particular keymaps
augroup for_markdown_ft
  au!
  au FileType markdown
        \ nnoremap <buffer> <silent> <Leader>mp :MarkdownPreview<CR>     |
        \ let  b:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'} |
        \ cabbrev <buffer> TF TableFormat
augroup END
"\ nnoremap <buffer> <silent> <Leader>t :Toc<CR>                  |

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
let g:startify_files_number = 7
let g:startify_change_to_dir = 0
let g:startify_session_persistence = 1
let g:startify_session_before_save = [ 'silent! NERDTreeClose' ]

" with devicons
" function! StartifyEntryFormat()
"   return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
" endfunction

function! s:list_commits()
  let l:not_repo = str2nr(system("git rev-parse >/dev/null 2>&1; echo $?"))
  if l:not_repo | return | endif
  let list_cmd = 'git log --oneline | head -n7'
  if executable('emojify') | let list_cmd .= ' | emojify' | endif
  let commits = systemlist(list_cmd)
  return map(commits, '{"line": matchstr(v:val, "\\s\\zs.*"), "cmd": "Git show ". matchstr(v:val, "^\\x\\+") }')
  " return map(commits, '{"line": {matchstr(v:val, "^\\x\\+"): matchstr(v:val, "\\s\\zs.*")}, "cmd": "Git show ". matchstr(v:val, "^\\x\\+") }')
endfunction

let g:startify_lists = [
      \ { 'header': ['   » SESSIONS    '], 'type': 'sessions' },
      \ { 'header': ['   » RECENT FILES @ '. getcwd()], 'type': 'dir' },
      \ { 'header': ['   » RECENT FILES'],   'type': 'files' },
      \ { 'header': ['   » REPO HISTORY '],  'type': function('s:list_commits') },
      \ ]

" /* for vc */

if executable('svn')
  let g:vc_browse_cache_all = 1
  map <silent> <leader>vB :VCBlame<CR>
  map <silent> <leader>vd :VCDiff<CR>
  map <silent> <leader>vdf :VCDiff!<CR>
  map <silent> <leader>vs :VCStatus<CR>
  map <silent> <leader>vsu :VCStatus -u<CR>
  map <silent> <leader>vsq :VCStatus -qu<CR>
  map <silent> <leader>vsc :VCStatus .<CR>
  map <silent> <leader>vl :VCLog!<CR>
  map <silent> <leader>vb :VCBrowse<CR>
  map <silent> <leader>vbm :VCBrowse<CR>
  map <silent> <leader>vbw :VCBrowseWorkingCopy<CR>
  map <silent> <leader>vbr :VCBrowseRepo<CR>
  map <silent> <leader>vbl :VCBrowseMyList<CR>
  map <silent> <leader>vbb :VCBrowseBookMarks<CR>
  map <silent> <leader>vbf :VCBrowseBuffer<CR>
  map <silent> <leader>vq :diffoff! <CR> :q<CR>
endif

" /* for goyo */
function! s:goyo_enter()
  silent !tmux set status off
  silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  set nonu
  set nornu
  set noshowmode
  set noshowcmd
  set scrolloff=999
  " Limelight
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  set nu
  set rnu
  set showmode
  set showcmd
  set scrolloff=5
  " Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" --------------------------------------------
" Functions
" --------------------------------------------

" toggle tagbar and toc
function! TToggle()
  if exists("t:opened_md_winid")
    call win_gotoid(t:opened_md_winid)
    execute("q")
    unlet t:opened_md_winid
  else
    if &ft == 'markdown'
      execute("Toc")
      let t:opened_md_winid = win_getid()
    else
      execute("TagbarToggle")
    endif
  endif
endfunction


function! s:EchoWarn(msg)
    echohl WarningMsg
    echom a:msg
    echohl None
endfunction


function! InstallRequirements()
  let req = {"pip": ['black', 'autopep8', 'isort', 'vint', 'proselint', 'gitlint'],
        \ "npm": ['prettier', 'fixjson', 'importjs'],
        \ "other": ['ag', 'fzf', 'ctags', 'clang-format']
        \ }
  let cmd_map = {"pip": "sudo pip install",
        \ "npm": "sudo npm install -g"}
  let pkg_map = {}

  " determine by system
  if executable("pacman")
    let cmd_map["other"] = "sudo pacman -S --noconfirm"
    let pkg_map["ag"] = "the_silver_searcher"
  elseif executable("apt")
    let cmd_map["other"] = "sudo apt install -y"
    let pkg_map["ag"] = "silversearcher-ag"
  else
    call s:EchoWarn("You must install " . string(req["other"]) . " by yourself.")
  endif

  function! s:IsInstalled(s, p)
    if a:s == 'other'
      return executable(a:p)
    else
      if a:s == 'pip'
        execute "!pip show " . a:p
      elseif a:s == 'npm'
        execute "!npm ls -g " . a:p
      endif
        return v:shell_error == 0
    endif
  endfunction

  for [src, pkgs] in items(req)
    for pkg in pkgs
      echom ">>> checking " . pkg . "..."
      if s:IsInstalled(src, pkg)
        echom pkg . " has been already installed."
      else
        if has_key(pkg_map, pkg)
          let cmd = cmd_map[src] . " " . pkg_map[pkg]
        else
          let cmd = cmd_map[src] . " " . pkg
        endif
        execute "!" . cmd
        if !s:IsInstalled(src, pkg)
          call s:EchoWarn("Failed to install " . pkg . ". Fix it by yourself.")
        endif
      endif
    endfor
  endfor
endfunction

" edit rc files
let s:vimrc_path = glob('~/.vimrc')
let s:extra_vimrc_path = s:vimrc_path . '.local'
let s:valid_extra_vimrc = filereadable(s:extra_vimrc_path)
function! EditRcFiles()
  execute 'tabe ' . s:vimrc_path
  let l:rc_id = win_getid()
  if exists('g:extra_init_vim_path') && exists('g:extra_init_vim_path')
    execute 'split ' . g:init_vim_path
    let l:init_id = win_getid()
    execute 'vsplit '. g:extra_init_vim_path
  endif
  call win_gotoid(l:rc_id)
  execute 'vsplit ' . s:extra_vimrc_path
  call win_gotoid(l:rc_id)
endfunction

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
  if has('termguicolors')
    if a:k ==# 'yes' && &termguicolors == 0
      call InitTermguicolors()
    elseif a:k ==# 'no' && &termguicolors == 1
      set notermguicolors
    endif
  endif
endfunction

" toggle background
" FIXME doesn't work at all
function! BackgroudToggle()
  let cs = g:colors_name
  if &background ==? 'dark'
    set background=light
  else
    set background=dark
  endif
  execute 'colorscheme ' . cs
  echom "Color: " . cs . " Background: " . &background
endfunction

" let background fit the clock
function! LetBgFitClock()
  let b:current_hour = strftime('%H')
  if b:current_hour >=8 && b:current_hour < 13
    set background=light
  else
    set background=dark
  endif
endfunction

" try to set termguicolors and return the status
function! InitTermguicolors()
  if has('termguicolors')
    if &termguicolors == 0
      " enhance termguicolors
      let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      set termguicolors
    endif
    return &termguicolors
  endif
endfunction

" initialize the colorscheme
function! InitColors()
  " gruvbox bubblegum birds-of-paradise blaquemagick buddy_modified dante
  " eclipse darkburn enigma eva01 evening evolution apprentice
  if $USER == 'k'
    if has('nvim')
      colorscheme solarized
    elseif InitTermguicolors()
      colorscheme atomic
    else
      colorscheme solarized
    endif
    call AfterChangeColorscheme()
  else
    colorscheme molokai
  endif
endfunction

" do some highlights before set colo
function! BeforeChangeColorscheme()
  call SetTermguiColors('no')
  call LetBgFitClock()
endfunction

" do some highlights after set colo
function! AfterChangeColorscheme()
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
    au ColorSchemePre * call BeforeChangeColorscheme()
    au ColorSchemePre atomic,NeoSolarized,ayu,palenight call SetTermguiColors('yes')
  endif
  au ColorScheme * call AfterChangeColorscheme()
augroup END

function! FitAirlineTheme(cname)
  if a:cname ==? 'NeoSolarized'
    let g:airline_theme='solarized'
  endif
endfunction

function! SetColorScheme(cname)
  if v:version < 801
    call SetTermguiColors('no') | call LetBgFitClock()
    if a:cname =~ '\vatomic|NeoSolarized|ayu|palenight'
      call SetTermguiColors('yes')
    endif
  endif
  execute 'colorscheme ' . a:cname
  call FitAirlineTheme(a:cname)
  if a:cname =~ '\v(seoul|gruvbox)'
    augroup ColoAirlineAug
      au!
      au BufReadPre,BufWinEnter,WinEnter * let w:airline_disabled = 1
    augroup END
  else
    augroup ColoAirlineAug
      au!
    augroup END
  endif
endfunction

" --------------------------------------------
" compatible with gui
" --------------------------------------------

if has('gui_running')
  set winaltkeys=no
  " lang
  set langmenu=en_US
  let $LANG = 'en_US.UTF-8'
  " window / tab / bar / ...
  set guioptions-=T
  set guioptions-=m
  set guioptions-=L
  set guioptions-=r
  set guioptions-=b
  set guioptions-=e
  set nolist
endif

" --------------------------------------------
" compatible with f cking windows
" --------------------------------------------

" gvim on win
if has("win32")
  set fileencodings=ucs-bom,utf-8,chinese,cp936
  set fileencoding=chinese
  source $VIMRUNTIME/delmenu.vim
  source $VIMRUNTIME/menu.vim
  language messages zh_CN.utf-8
endif

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
" set background=dark

" italic
set t_ZH=[3m
set t_ZR=[23m

" load local configuration
if s:valid_extra_vimrc
  execute 'source ' . s:extra_vimrc_path
endif

" fallback
if !exists('g:colors_name')
  call SetColorScheme('molokai')
endif

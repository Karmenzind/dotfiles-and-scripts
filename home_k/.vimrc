" vim:set et sw=2 ts=2 tw=78 ft=vim:
" Github: https://github.com/Karmenzind/dotfiles-and-scripts

let s:is_win = has("win32")
if s:is_win
  set belloff=all
  set fileencodings=ucs-bom,utf-8,chinese,cp936
  set fileencoding=chinese
  language messages zh_CN.utf-8
  let &shell= executable("pwsh")? 'pwsh': 'powershell'
  let &shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"

  let g:vimroot = glob('~') .. '\vimfiles'
else
  let g:vimroot = glob('~') .. '/.vim'
endif

let b:current_hour = strftime('%H')
let s:bg_light = b:current_hour >=8 && b:current_hour < 17
let g:plugged_dir = g:vimroot .. '/plugged'

" --------------------------------------------
" general keymaps and abbreviations
" --------------------------------------------

function s:IsHHKB() abort
  " TODO (k): <2024-02-14 19:50> windows
  if !s:is_win && !empty(system("grep 'HHKB' /proc/bus/input/devices"))
      return v:true
  endif
  return v:false
endfunction
let s:is_hhkb = s:IsHHKB()

if s:is_hhkb
  noremap <BACKSPACE> <NOP>
  map <BACKSPACE> <Leader>
endif

function! s:NoSearchCabbrev(abbr, expanded)
  execute printf("cabbrev <expr> %s (getcmdtype() == ':') ? \"%s\" : \"%s\"", a:abbr, a:expanded, a:abbr)
endfunction

function! s:OpenTerm() abort
  if has('nvim')
    sp
    terminal
    call feedkeys('A')
  else
    if s:is_win && executable('pwsh')
      execute ':terminal pwsh'
    else
      terminal
    endif
  endif
endfunction

noremap <Leader>E  :call EditRcFilesV2()<CR>
noremap <Leader>R  :source $MYVIMRC<CR> :echom 'Vimrc reloaded :)'<CR>
noremap <Leader>S  :source %<CR> :echom expand('%') . ' sourced :)'<CR>
" noremap <Leader>T  :terminal<CR>
noremap <Leader>T  <cmd>call <SID>OpenTerm()<CR>

" /* command */
call s:NoSearchCabbrev("w!!", "w !sudo tee %")
call s:NoSearchCabbrev("GI", "GoImport")
call s:NoSearchCabbrev("th", "tab<SPACE>help")
call s:NoSearchCabbrev("sss", "s/\v(,)\s*/\1\r/g")

" /* workspace, layout, format and others */
nnoremap <silent> <C-n> gt
nnoremap <silent> <C-p> gT

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

" /* initialize Plug itself */
if !has("win32")
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !mkdir -p ~/.vim/autoload &&
            \ wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            \ -O ~/.vim/autoload/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
else
  if !isdirectory(g:plugged_dir) | call mkdir(g:plugged_dir, 'p') | endif
  let g:plugged_dir = glob(g:plugged_dir)
  if !filereadable(glob('~') .. '\vimfiles\autoload\plug.vim')
    echom "Initializing vim-plug..."
    " XXX
    silent ! powershell -Command "
    \ New-Item -Path ~\vimfiles -Name autoload -Type Directory -Force;
    \ Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' -OutFile ~\vimfiles\autoload\plug.vim
    \ "
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

" function! BuildYCM(info)
"   if a:info.status == 'installed' || a:info.force
"      !./install.py --clang-completer --clangd-completer --system-libclang --go-completer --ts-completer
"   endif
" endfunction

function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

call plug#begin(g:plugged_dir)
Plug 'junegunn/vim-plug'

" /* coding tools */
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'

Plug has('nvim')? 'windwp/nvim-autopairs': 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Shougo/context_filetype.vim'
Plug 'liuchengxu/vista.vim'
" Plug 'Shougo/echodoc.vim'
Plug 'w0rp/ale' " Asynchronous Lint Engine
if has("nvim")
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  Plug 'kevinhwang91/promise-async' | Plug 'kevinhwang91/nvim-ufo'

  Plug 'williamboman/mason.nvim' | Plug 'williamboman/mason-lspconfig.nvim'

  Plug 'neovim/nvim-lspconfig'

  " lspkind adds vscode-like pictograms to neovim built-in lsp:
  Plug 'onsails/lspkind.nvim'

  Plug 'kosayoda/nvim-lightbulb'  " show code action symbol
  Plug 'weilbith/nvim-code-action-menu', {'on': 'CodeActionMenu'}

  " cmp
  Plug 'hrsh7th/nvim-cmp',                    {'branch': 'main'}
  Plug 'hrsh7th/cmp-nvim-lsp-signature-help', {'branch': 'main'}
  Plug 'hrsh7th/cmp-nvim-lsp',                {'branch': 'main'}
  Plug 'hrsh7th/cmp-buffer',                  {'branch': 'main'}
  Plug 'hrsh7th/cmp-path',                    {'branch': 'main'}
  Plug 'hrsh7th/cmp-calc',                    {'branch': 'main'}
  Plug 'hrsh7th/cmp-cmdline',                 {'branch': 'main'}
  Plug 'hrsh7th/cmp-emoji',                   {'branch': 'main'}
  if exists('$TMUX')
    Plug 'andersevenrud/cmp-tmux'
  endif
  Plug 'quangnguyen30192/cmp-nvim-ultisnips'

  " language specs
  Plug 'Hoffs/omnisharp-extended-lsp.nvim'

  " debug
  Plug 'mfussenegger/nvim-dap'
  Plug 'mfussenegger/nvim-dap-python'
  Plug 'leoluz/nvim-dap-go'
  Plug 'rcarriga/nvim-dap-ui'
  Plug 'rcarriga/cmp-dap'
  Plug 'theHamsta/nvim-dap-virtual-text'
else
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " if has("win32")
  "   Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " else
  "   Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM'), 'frozen': v:true }
  " endif
endif

" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
" Plug 'mattn/emmet-vim'
" TODO (k): <2022-10-15>
" Plug 'puremourning/vimspector'

" /* version control (vcs) | workspace */
Plug 'tpope/vim-fugitive'
" if executable("svn")
"   Plug 'Karmenzind/vc-svn.vim', {'branch': 'dev', 'frozen': 1}
" endif

if has('nvim')
  Plug 'nvim-tree/nvim-tree.lua'
else
  Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
endif
" Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle'] }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 't9md/vim-choosewin'
if has('nvim')
  Plug 'goolord/alpha-nvim'
  Plug 'kyazdani42/nvim-web-devicons'
else
  if !s:is_win
    Plug 'mhinz/vim-startify'
  endif
endif
" Plug 'bagrat/vim-workspace' " tab bar

" /* Search */
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/vim-slash' " enhancing in-buffer search experience
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
if has("nvim")
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
else
  Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
endif

" /* Go */
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" /* Python */
Plug 'tmhedberg/SimpylFold', { 'for': 'python' } " code folding
Plug 'raimon49/requirements.txt.vim'
Plug 'vim-scripts/indentpython.vim'
Plug 'tweekmonster/django-plus.vim', { 'for': 'python' }

" /* Write doc */
Plug 'godlygeek/tabular'
Plug 'mzlogin/vim-markdown-toc'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'nelstrom/vim-markdown-folding', { 'for': 'markdown' }
Plug 'mklabs/vim-markdown-helpfile'
Plug 'Traap/vim-helptags'

" /* Experience | Enhancement */
" if !has('clipboard') | Plug 'kana/vim-fakeclip' | endif
" Plug 'junegunn/limelight.vim'
" Plug 'vipul-sharma20/vim-registers'
Plug 'dahu/vim-lotr'
if has('nvim')
  " Plug 'MunifTanjim/nui.nvim'
  " Plug 'folke/noice.nvim'
  " Plug 'MunifTanjim/nui.nvim'

  Plug 'nvim-lua/plenary.nvim'
  Plug 'folke/todo-comments.nvim', {'branch': 'main'}
  " Plug 'gennaro-tedesco/nvim-peekup'
  Plug 'tversteeg/registers.nvim', {'branch': 'main'}
else
  " Plug 'utubo/vim-registers-lite.nvim'
  Plug 'karmenzind/registers.vim', {'branch': 'dev', 'frozen': 1}
endif
Plug 'karmenzind/vim-tmuxlike', {'branch': 'dev', 'frozen': 1}
Plug 'skywind3000/vim-quickui'
Plug 'skywind3000/asyncrun.vim'

" /* Funny Stuff */
" Plug 'junegunn/vim-emoji', { 'for': 'markdown,gitcommit' }
" Plug 'vim-scripts/TeTrIs.vim'

" /* Syntax | Fold */
Plug 'posva/vim-vue'
Plug 'cespare/vim-toml'
Plug 'Yggdroot/indentLine'
Plug 'chr4/nginx.vim'
Plug 'pangloss/vim-javascript'
Plug 'mtdl9/vim-log-highlighting'
" Plug 'demophoon/bash-fold-expr', { 'for': 'sh' }
" Plug 'vim-scripts/txt.vim', { 'for': 'txt' }

" /* Appearance */
Plug 'flazz/vim-colorschemes'
if has('nvim')
  let g:line_plugin = 'lualine'
  Plug 'nvim-lualine/lualine.nvim'
else
  let g:line_plugin = 'airline'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
endif
Plug 'gerardbm/vim-atomic'
Plug 'icymind/NeoSolarized'
Plug 'KKPMW/sacredforest-vim'
Plug 'junegunn/seoul256.vim'
Plug 'arcticicestudio/nord-vim'
if has('nvim')
  Plug 'katawful/kat.nvim', { 'tag': '3.0' }
  Plug 'projekt0n/github-nvim-theme'
  Plug 'uloco/bluloco.nvim' | Plug 'rktjmp/lush.nvim'
  Plug 'rockerBOO/boo-colorscheme-nvim'
  Plug 'kyazdani42/blue-moon' " no airline theme
  Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
endif
if !has('win32')
  Plug has('nvim')? 'kyazdani42/nvim-web-devicons': 'ryanoasis/vim-devicons' " load after other plugins
endif

" /* local */
" Plug '~/Localworks/dbcli.vim'

call plug#end()

" internal plugins
runtime macros/matchit.vim
" runtime! ftplugin/man.vim
runtime! ftplugin/qf.vim

function! Plugged(name) abort
  return has_key(g:plugs, a:name)
endfunction
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
  set guifont=Monaco\ Nerd\ Font\ Mono:h12
  " set guifontwide='Monaco\ Nerd\ Font:h12,consolas:h12'
elseif !exists("g:neovide") " crash on neovide
  set guifont=Monaco\ Nerd\ Font\ Mono\ 12
endif
set cursorline cursorcolumn
set showmode
set cmdheight=2
set laststatus=2
set matchtime=5
set nowrap

" set noshowmode
" set whichwrap+=<,>,h,l
if has_key(plugs, 'vim-devicons')
  set statusline=%f\ %{WebDevIconsGetFileTypeSymbol()}\ %h%w%m%r\ %=%(%l,%c%V\ %Y\ %=\ %P%)
else
  set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]
endif

" /* line number */
set number

function! s:RelNoToggle(mode)
  if !has('nvim')
    if &ft =~? '\v(startify|registers|leaderf)' | return | endif
  endif
  " respect buffer settings
  if getbufvar(winbufnr(0), '&nu') == 0 | return | endif
  if a:mode == "in"
    if &nu | set rnu | else | set nu rnu | endif
  endif
  if a:mode == "out"
    if &nu | set nornu | else | set nu rnu | endif
  endif
endfunction

augroup relative_number_toggle
  autocmd!
  if !has('nvim') && has_key(plugs, "LeaderF")
    autocmd FileType leaderf setlocal nonu nornu
  endif
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * call s:RelNoToggle("in")
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * call s:RelNoToggle("out")
augroup END

" /* layout */
set splitbelow splitright

" /* operate and edit */
set mouse=a
set backspace=indent,eol,start  " more powerful backspacing
" make * reg the default
if has('clipboard') | set clipboard=unnamed | endif
if has('gui_running')
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif
set scrolloff=5

" /* Enable folding */
set foldlevel=99
let g:fold_offset = 4
augroup fold_specs
  au!
  au FileType vim let b:fold_offset = 5
augroup END


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

  au FileType yaml.docker-compose setlocal sts=2 ts=2 sw=2

  au FileType help setlocal nu

  au FileType make setlocal noexpandtab

  au BufNewFile,BufRead Jenkinsfile setf groovy

  au BufNewFile,BufRead *.{vim},*vimrc
        \ setlocal tabstop=2          |
        \ setlocal softtabstop=2      |
        \ setlocal shiftwidth=2       |
        \ setlocal formatoptions-=cro |
        \ setlocal foldlevel=2        |
        \ setlocal foldmethod=expr    |
        \ setlocal foldexpr=VimScriptFold(v:lnum)

  au BufNewFile,BufRead *.go
        \ setlocal foldmethod=syntax

  au BufNewFile,BufRead *.py
        \ setlocal autoindent            |
        \ setlocal sidescroll=5          |
        \ setlocal cc=120                |
        \ let b:python_highlight_all = 1 |
        \ setlocal complete+=t           |
        \ setlocal formatoptions-=t      |
        \ setlocal commentstring=#%s     |
        \ setlocal define=^\s*\\(def\\\\|class\\)
  " \ set listchars+=precedes:<,extends:>
  " \ set textwidth=79 |

  au BufNewFile,BufRead *.js,*.html,*.css,*.yml,*.toml,*.vue
        \ setlocal tabstop=2     |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2

  au BufNewFile,BufRead *.json
        \ setlocal tabstop=2     |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2  |
        \ setlocal foldmethod=syntax

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

function! s:UpdateHeader() abort
  let bufpath = resolve(glob('%'))
  if bufpath =~ '.*dotfiles-and-scripts.*' && !empty(&cms)
    let pref = &cms =~ ".* %s"? printf(&cms, ""): printf(&cms, " ")
    let pref = substitute(pref, "/", "\\\\/", "g")
    let pat = pref .. "Last Modified: "
    let nr = line('$')
    let endnr = nr > 10? 10: nr
    let c = printf("1,%ss/%s.*/%s/", endnr, pat, pat .. strftime("%Y-%m-%d %T"))
    try
      normal m"
      call execute(c)
      normal `"
    catch
      call EchoWarn(v:exception)
    endtry
  endif
endfunction

augroup file_headers
  au!
  au BufNewFile *.sh
        \ call setline(1, '#!/usr/bin/env bash')                   |
        \ call append(line('.'), '')                               |
        \ normal! Go
  au BufNewFile *.py
        \ call setline(1, '#!/usr/bin/env python')                 |
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
  au BufWritePre,FileWritePre * call <SID>UpdateHeader()
augroup END

" --------------------------------------------
" plugin configuration
" --------------------------------------------

" /* for YCM */
if has_key(plugs, 'YouCompleteMe')
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

  let g:ycm_confirm_extra_conf = 0
  let g:ycm_add_preview_to_completeopt = 1
  let g:ycm_autoclose_preview_window_after_completion = 1

  let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
  let g:ycm_complete_in_comments = 1
  let g:ycm_complete_in_strings = 1
  let g:ycm_server_python_interpreter = 'python'
  let g:ycm_python_binary_path = 'python3'
  let g:ycm_goto_buffer_command = 'horizontal-split'

  let g:ycm_seed_identifiers_with_syntax = 1
  let g:ycm_collect_identifiers_from_tags_files = 1
  " let g:ycm_collect_identifiers_from_comments_and_strings = 1
  " let g:ycm_max_num_candidates = 14
  " let g:ycm_max_num_identifier_candidates = 7

  let g:ycm_semantic_triggers = {
  \   'python': [ 're!(import\s+|from\s+(\w+\s+(import\s+(\w+,\s+)*)?)?)' ],
  \   'html': ['<', '"', '</', ' '],
  \   'scss,css': [ 're!^\s{2,4}', 're!:\s+' ]
  \ }

  let g:__rtp = &rtp
  let g:ycm_extra_conf_vim_data = ['g:__rtp']

  " set completeopt-=preview
  set completeopt+=longest,menu
  " if has('patch-8.1.1902')
  "     set completeopt+=popup
  "     set completepopup=height:10,width:60,highlight:Pmenu,border:off
  "     set pumwidth=10
  " endif

  let g:ycm_language_server = [
        \ {"name": "vue", "filetypes": ["vue"], "cmdline": ["vls"] },
        \ {"name": "vim", "filetypes": ["vim"], "cmdline": ["vim-language-server", '--stdio'] },
        \ ]

  if !has('nvim')
    let g:ycm_auto_hover = ''
  endif

  augroup ycm_behaviours
    au!
    au FileType python,go,sh,vim
        \ nmap K <plug>(YCMHover)
  augroup END

  nnoremap <silent> <Leader>g   :YcmCompleter GoTo<CR>
  nnoremap <silent> <Leader>dd  :YcmCompleter GoToDefinitionElseDeclaration<CR>
  nnoremap <silent> <Leader>rf  :YcmCompleter GoToReferences<CR>
  " nnoremap <silent> <Leader>doc :YcmCompleter GetDoc<CR>
  nnoremap <Leader>rr  :YcmCompleter RefactorRename<SPACE>
endif

" /* for XXX */
function! s:FzfToNERDTree(lines)
  if len(a:lines) == 0 | return | endif
  let path = glob(a:lines[0])
  if empty(path)
    echoerr "Invalid path: " .. a:lines[0]
    return
  endif
  if has("nvim")
    " execute 'CHADopen --always-focus ' .. path
    execute 'NvimTreeFindFile '
    wincmd p
  else
    if get(g:, "loaded_nerd_tree", 0) == 0
        execute 'NERDTree'
    endif
    execute 'NERDTreeFind ' .. path
  endif
endfunction

" /* for NERDTree */
nnoremap <silent> <leader>N :NERDTreeFind<CR>
nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
let g:NERDTreeIgnore = ['\.pyc$', '\~$', '__pycache__[[dir]]', '\.swp$']
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
if g:line_plugin == 'airline'
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
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_splits = 0
  " let g:airline#extensions#searchcount#enabled = 0

  let g:airline#extensions#tabline#buffer_idx_mode = 1
  nmap <leader>1 <Plug>AirlineSelectTab1
  nmap <leader>2 <Plug>AirlineSelectTab2
  nmap <leader>3 <Plug>AirlineSelectTab3
  nmap <leader>4 <Plug>AirlineSelectTab4
  nmap <leader>5 <Plug>AirlineSelectTab5
  nmap <leader>6 <Plug>AirlineSelectTab6
  nmap <leader>7 <Plug>AirlineSelectTab7
  nmap <leader>8 <Plug>AirlineSelectTab8
  nmap <leader>9 <Plug>AirlineSelectTab9
  nmap <leader>- <Plug>AirlineSelectPrevTab
  nmap <leader>+ <Plug>AirlineSelectNextTab

  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#extensions#tabline#buffer_idx_format = {
        \ '0': '0 ',
        \ '1': '1 ',
        \ '2': '2 ',
        \ '3': '3 ',
        \ '4': '4 ',
        \ '5': '5 ',
        \ '6': '6 ',
        \ '7': '7 ',
        \ '8': '8 ',
        \ '9': '9 '
        \}

  let g:airline#extensions#tabline#tab_nr_type = 2

  let g:airline#extensions#tabline#show_buffers = 0
  let g:airline#extensions#tabline#tabs_label = 't'
  let g:airline#extensions#tabline#buffers_label = 'b'
endif

" /* for fzf */
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-n': function('s:FzfToNERDTree'),
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:fzf_preview_window = 'right:60%'
let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags -R'

if s:is_win
  " XXX bash path
  let g:fzf_vim = {
    \ 'preview_bash': 'C:\Program\ Files\Git\git-bash.exe',
    \ 'preview_window': ['hidden,right,50%,<70(up,40%)', 'ctrl-/'],
    \ }
else
  let g:fzf_history_dir = '~/.local/share/fzf-history'
endif

let s:__use_tmux = v:false
if !s:is_win && exists('$TMUX')
  let g:__tmux_version = str2float(matchstr(system('tmux -V'), '\v[0-9]+\.[0-9]+'))
  if g:__tmux_version >= 3.2
    let s:__use_tmux = v:true
  endif
endif

if s:__use_tmux
  let g:fzf_layout = { 'tmux': '-p90%,60%' }
else
  if (has('nvim') || has("popupwin"))
    let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
  else
    let g:fzf_layout = { 'down': '~51%' }
  endif
  let g:fzf_colors = {
    \ 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Comment'],
    \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
    \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
    \ 'hl+':     ['fg', 'Statement'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'Exception'],
    \ 'marker':  ['fg', 'Keyword'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment'] }
endif

command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, '--hidden', <bang>0)
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)
command! -bar -nargs=? -bang Maps call fzf#vim#maps(<q-args>, <bang>0)

nnoremap <Leader>ff :Files<CR>
if s:is_win
  nnoremap <Leader>fa :Rg<SPACE>
else
  nnoremap <Leader>fa :Ag<SPACE>
endif
nnoremap <Leader>fr :Rg<SPACE>
nnoremap <Leader>fg :Rg<SPACE>
nnoremap <Leader>fl :Lines<SPACE>
nnoremap <Leader>fL :BLines<SPACE>
nnoremap <Leader>fb :Buffers<CR>
nnoremap <Leader>fw :Windows<CR>
nnoremap <Leader>fs :Snippets<CR>
" nnoremap <Leader>fh :History/<CR>
nnoremap <Leader>fq :FzfQF<CR>

" /* for devicons */
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
if !s:is_win | let g:WebDevIconsOS = 'ArchLinux' | endif

" /* LeaderF */
if s:is_win && Plugged('LeaderF')
  let g:Lf_ExternalCommand = 'fd -t f --strip-cwd-prefix -H -L -E .git -E *.swp %s'
  let g:Lf_ShowHidden = 1
  let g:Lf_WindowPosition = 'popup'
  let g:lf_UseMemoryCache = 0
  let g:lf_UseCache = 0
  let g:Lf_PopupWidth = 0.5
  let g:Lf_PopupHeight = 0.6
  nnoremap <Leader>ff <cmd>Leaderf file<CR>
  nnoremap <Leader>fg :Leaderf rg<space>
  nnoremap <Leader>fb :Leaderf buffer<CR>
  nnoremap <Leader>fL :Leaderf line<CR>
  nnoremap <Leader>fw :Leaderf windows<CR>

  let g:Lf_CommandMap = {'<C-]>': ['<C-V>']}
  let g:Lf_UseVersionControlTool = 0
endif


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
call s:NoSearchCabbrev("UE", "UltiSnipsEdit")
let g:UltiSnipsExpandTrigger = '<c-j>'
" FIXME (k): <2022-03-23> doesn't work any more
" let g:UltiSnipsListSnippets = '<F9>'
let g:UltiSnipsEditSplit = 'context'
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsSnippetStorageDirectoryForUltiSnipsEdit = g:vimroot .. '/mysnippets'
let g:UltiSnipsSnippetDirectories = ['UltiSnips', 'mysnippets']
let g:UltiSnipsEnableSnipMate = 1
let g:UltiSnipsNoPythonWarning = 1
let g:snips_author = 'k'
let g:snips_email = 'valesail7@gmail.com'
let g:snips_github = 'https://github.com/Karmenzind/'

" /* for ale */
" trim whitespaces surrounded in docstrings
function! FixSurroundedWhiteSpaces(buffer, lines)
  return map(a:lines, {idx, line -> substitute(line, '\v^(\s*""")\s+(.+)\s+(""")', '\1\2\3', '')})
endfunction

" no linters for nvim
if has('nvim')
  let g:ale_enabled = 0
else
  let g:ale_linter_aliases = {
        \ 'vue': ['vue', 'javascript', 'html']
        \ }
  let g:ale_linters = {
        \ 'vim': ['vint'],
        \ 'python': ['pylint', 'pydocstyle', 'flake8'],
        \ 'markdown': ['mdl', 'prettier', 'proselint', 'alex'],
        \ 'text': ['proselint', 'alex', 'redpen'],
        \ 'vue': ['htmlhint', 'jshint', 'stylelint'],
        \ 'javascript': ['jshint', 'prettier', 'importjs'],
        \ 'gitcommit': ['gitlint'],
        \ 'dockerfile': ['hadolint'],
        \ 'sql': ['sqlint'],
        \ 'cpp': ['gcc'],
        \ 'html': ['prettier', 'htmlhint'],
        \ 'go': ['golangci-lint'],
        \ }

  nmap <silent> [d <Plug>(ale_previous)
  nmap <silent> ]d <Plug>(ale_next)

  let g:ale_warn_about_trailing_whitespace = 0
  let g:ale_lint_on_text_changed = 'normal'
  let g:ale_lint_on_insert_leave = 1

  " format
  let g:ale_echo_msg_format = '%severity% (%linter%) %code:% %s'
  let g:ale_echo_msg_error_str = ' E'
  let g:ale_echo_msg_info_str = ' I'
  let g:ale_echo_msg_warning_str = ' W'
endif

let g:ale_fixers = {
      \  '*': ['trim_whitespace'],
      \  'c': ['clang-format'],
      \  'javascript': ['prettier', 'importjs'],
      \  'sh': ['shfmt'],
      \  'go': ['gofmt', 'goimports'],
      \  'python': ['isort', 'autopep8', 'FixSurroundedWhiteSpaces', 'autoflake'],
      \  'json': ['prettier'],
      \  'sql': ['pgformatter'],
      \  'vue': ['eslint', 'prettier'],
      \  'yaml': ['prettier'],
      \  'css': ['prettier'],
      \  'html': ['prettier'],
      \  'lua': ['stylua'],
      \  'php': ['php_cs_fixer'],
      \ }

let g:ale_maximum_file_size = 1024 * 1024
" let g:ale_set_balloons_legacy_echo = 1

" hover
let g:ale_floating_preview = 1
let g:ale_hover_to_preview = 1
let g:ale_hover_to_floating_preview = 1

" options
let g:ale_python_mypy_ignore_invalid_syntax = 1
let g:ale_python_mypy_options = '--incremental'
let g:ale_python_pylint_options = '--max-line-length=120 --rcfile $HOME/.config/pylintrc'
" let g:ale_python_autopep8_options = '--max-line-length=120'
let g:ale_python_flake8_options = '--max-line-length=120 --extend-ignore=E722,E741,E402,E501'
let g:ale_python_pydocstyle_options = '--ignore=D200,D203,D204,D205,D211,D212,D213,D400,D401,D403,D415'
let g:ale_python_autoflake_options = '--remove-all-unused-imports --ignore-init-module-imports'
" let g:ale_javascript_prettier_options = '-c'
" let g:ale_javascript_eslint_options = '--ext .js,.vue'
let g:ale_sql_sqlfmt_executable = exepath("sqlfmt")

let g:ale_sql_sqlfmt_options = '-u'
let g:ale_lua_stylua_options = '--indent-type Spaces'
let g:ale_dprint_config = '$HOME/.dprint.json'
let g:ale_dprint_use_global = 1

" others
let g:ale_c_parse_compile_commands = 1
let g:ale_typescript_tslint_ignore_empty_files = 1

" experimental
let g:ale_hover_cursor = 1
let g:ale_set_balloons = 1
let g:ale_hover_to_preview = 1
let g:ale_floating_preview = 1

nmap <silent> <Leader>al <Plug>(ale_lint)
nmap <silent> <Leader>af <Plug>(ale_fix)
nmap <silent> <Leader>at <Plug>(ale_toggle)
call s:NoSearchCabbrev("AF", "ALEFix")

" /* for vim-visual-multi */
let g:VM_maps = {"Find Under": '<space>n'}

" /* for vim-markdown | markdown-preview */
" vim-markdown
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:tex_conceal = "" | let g:vim_markdown_math = 1

" markdown-preview
" let g:mkdp_browserfunc = 'MKDP_browserfunc_default'
" let g:mkdp_browser = 'chromium-browser'
let g:mkdp_open_to_the_world = 1
let g:mkdp_open_ip = '0.0.0.0'
let g:mkdp_port = '13333'

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
    \ 'disable_sync_scroll': 1,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {}
    \ }
let g:mkdp_browser = 'chromium'

" tmux pane or terminal
function! s:TermExecute(cmd)
  if has_key(environ(), "TMUX")
    call system(printf("tmux split-window \"%s\"", a:cmd))
  else
    if has("nvim") | execute "split" | endif
    execute "terminal " .. a:cmd
  endif
endfunction

function! GetBrowser() abort
  if s:is_win
    let p = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    return glob(p)
  else
    for p in ['google-chrome', 'google-chrome-stable', 'chroimium', 'fire']
      if executable(p) | return p | endif
    endfor
  endif
endfunction

function! s:PreviewWithMLP() abort
  if &ft != "markdown" | echom "Only support markdown" | return | endif

  if !executable("mlp")
    echom "mlp not found (Install with: pip install markdown_live_preview)" | return
  endif

  let mlp_cmd = "mlp --no-browser -p 13333 -o " .. expand("%")
  call s:TermExecute(mlp_cmd)

  let b = GetBrowser()
  if empty(b)
    echom "Available browser not found."
  else
    call s:TermExecute(b .. " http://localhost:13333")
  endif
endfunction
nnoremap <Leader>mp :call <SID>PreviewWithMLP()<CR>

" particular keymaps
augroup for_markdown_ft
  au!
  au FileType markdown
        \ let  b:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'} |
        \ cabbrev <buffer> TF TableFormat
  " FIXME (k): <2022-03-23> no search
augroup END

" /* for SimpylFold */
let g:SimpylFold_docstring_preview = 1
let g:SimpylFold_fold_docstring = 0
let g:SimpylFold_fold_import = 1
" let g:SimpylFold_fold_blank = 1


" /* for choosewin */
" invoke with '-'
" nmap  -  <Plug>(choosewin)
" " if you want to use overlay feature
" let g:choosewin_overlay_enable = 1

" /* for vim-tmuxlike */
" nmap <silent> <c-\> <Plug>(tmuxlike-prefix)
nmap <c-\> <Plug>(tmuxlike-prefix)
if s:is_hhkb
  " XXX (k): <2022-06-23> <C-BS> didn't work
  nmap  <Plug>(tmuxlike-prefix)
endif

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

augroup startify_aug
  au!
  au FileType startify IndentLinesDisable
augroup END

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
if executable('svn') && Plugged('vc-svn.vim')
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
  set nonu nornu noshowmode noshowcmd scrolloff=999
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

" /* for indentline */
let g:indentLine_fileTypeExclude = ['alpha', 'startify']
nnoremap <silent> <Leader>it :IndentLinesToggle<CR>
" let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_setConceal = 0
let g:indentLine_enabled = 1

" /* for emmet */
let g:user_emmet_leader_key = '<leader>y'

" /* for coc */
if has_key(plugs, 'coc.nvim')
  set nobackup
  set nowritebackup
  set updatetime=300
  set signcolumn=yes

  inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

  inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : CheckBackspace() ? "\<Tab>" : coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  nmap <silent> [d <Plug>(coc-diagnostic-prev)
  nmap <silent> ]d <Plug>(coc-diagnostic-next)

  nmap <silent> <leader>g <Plug>(coc-definition)
  " nmap <silent> gy <Plug>(coc-type-definition)
  " nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> <leader>rf <Plug>(coc-references)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call ShowDocumentation()<CR>
  nnoremap <silent> <leader>e <Plug>(coc-diagnostic-info)

  function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
      call CocActionAsync('doHover')
    else
      call feedkeys('K', 'in')
    endif
  endfunction

  autocmd CursorHold * silent call CocActionAsync('highlight')

  nmap <leader>rn <Plug>(coc-rename)

  xmap <leader>f  <Plug>(coc-format-selected)
  nmap <leader>f  <Plug>(coc-format-selected)

  augroup mygroup
    autocmd!
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  xmap <leader>ca  <Plug>(coc-codeaction-selected)
  nmap <leader>ca  <Plug>(coc-codeaction-selected)
  nmap <leader>ca  <Plug>(coc-codeaction)
  nmap <leader>qf  <Plug>(coc-fix-current)
  nmap <leader>cl  <Plug>(coc-codelens-action)

  " Map function and class text objects
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)

  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  endif

  nmap <silent> <C-s> <Plug>(coc-range-select)
  xmap <silent> <C-s> <Plug>(coc-range-select)
  command! -nargs=0 Format :call CocActionAsync('format')
  command! -nargs=? Fold :call CocAction('fold', <f-args>)
  command! -nargs=0 OR   :call CocActionAsync('runCommand', 'editor.action.organizeImport')

  " Add (Neo)Vim's native statusline support.
  " NOTE: Please see `:h coc-status` for integrations with external plugins that
  " provide custom statusline: lightline.vim, vim-airline.
  " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " " Mappings for CoCList
  " " Show all diagnostics.
  " nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
  " " Manage extensions.
  " nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
  " " Show commands.
  " nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
  " " Find symbol of current document.
  " nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
  " " Search workspace symbols.
  " nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
  " " Do default action for next item.
  " nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
  " " Do default action for previous item.
  " nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
  " " Resume latest coc list.
  " nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

  let g:coc_global_extensions = [ 'coc-json', 'coc-git', 'coc-snippets',
        \ 'coc-docker', 'coc-sh', 'coc-sql', 'coc-toml', 'coc-go',
        \ 'coc-pyright', 'coc-lua', 'coc-tsserver' ]
  if has("win32")
    call add(g:coc_global_extensions, "coc-powershell")
  endif

  " snippets
  let g:coc_snippet_next = '<c-j>'
  let g:coc_snippet_prev = '<c-k>'
  imap <C-j> <Plug>(coc-snippets-expand-jump)
  " xmap <leader>x  <Plug>(coc-convert-snippet)
endif


" /* for vista.vim */
noremap <Leader>V :Vista!!<CR>
noremap <Leader>fc :Vista finder<CR>
let g:vista_sidebar_width = 40
let g:vista_echo_cursor = 0
let g:vista_echo_cursor_strategy = 'both'
" let g:vista_highlight_whole_line = 1

if has('nvim')
  let g:vista_executive_for = {
    \ 'go': 'nvim_lsp',
    \ 'lua': 'nvim_lsp',
    \ 'yaml': 'nvim_lsp',
    \ 'toml': 'nvim_lsp',
    \ }
elseif Plugged("coc.nvim")
  let g:vista_executive_for = {
    \ 'lua': 'coc',
    \ 'yaml': 'coc',
    \ 'toml': 'coc',
    \ 'ps1': 'coc',
    \ 'tsx': 'coc',
    \ 'typescriptreact': 'coc',
    \ }
endif

augroup vista_aug
  au!
  au FileType vista,vista_kind set nu rnu
  au FileType vista,vista_kind nnoremap <buffer> <silent> K :<c-u>call vista#cursor#TogglePreview()<CR>

augroup END

" /* for vim-vue */
let g:vue_pre_processors = []

" /* for vim-javascript */
augroup javascript_folding
  au!
  au FileType javascript setlocal foldmethod=syntax
augroup END

" /* for vim-go */
if Plugged("vim-go")
  let g:go_term_mode = "split"
  let g:go_term_enabled = 1
  let g:go_term_reuse = 1
  let g:go_term_close_on_exit = 0
  let g:go_term_height = 20
  let g:go_term_width = 30
  let g:go_doc_balloon = 0
  let g:go_doc_keywordprg_enabled = 0

  let g:go_code_completion_enabled = 1

  let g:go_fmt_autosave = 0
  let g:go_mod_fmt_autosave = 0

  augroup go_map
    au!
    au FileType go nmap <leader>rt <Plug>(go-run-tab)
    au FileType go nmap <leader>rs <Plug>(go-run-split)
    au FileType go nmap <leader>rv <Plug>(go-run-vertical)
    au FileType go call s:NoSearchCabbrev("GI", "GoImport")
    au FileType go call s:NoSearchCabbrev("GR", "GoRun")
  augroup END
endif
" --------------------------------------------
" Functions
" --------------------------------------------

function! EchoWarn(msg)
  echohl WarningMsg | echom '[✘] ' .. a:msg | echohl None
endfunction

" edit rc files
" TODO (k): <2022-10-11> check opened
if has('win32')
  let s:vimrc_path = glob('~/_vimrc')
  let g:init_vim_path = glob('~/AppData/Local/nvim/init.vim')
  let g:init_lua_path = glob('~/AppData/Local/nvim/init.lua')
  let g:config_lua_path = glob('~/AppData/Local/nvim/lua/config.lua')
  let s:extra_vimrc_path = s:vimrc_path .. '_local'
  let g:extra_init_vim_path = g:init_vim_path .. '_local'
  let g:coc_settings_json_path = glob('~/vimfiles/coc-settings.json')
else
  let s:vimrc_path = glob('~/.vimrc')
  let g:init_vim_path = glob('~/.config/nvim/init.vim')
  let g:init_lua_path = glob('~/.config/nvim/init.lua')
  let g:config_lua_path = glob('~/.config/nvim/lua/config.lua')
  let g:coc_settings_json_path = glob('~/.vim/coc-settings.json')
  let s:extra_vimrc_path = s:vimrc_path .. '.local'
  let g:extra_init_vim_path = g:init_vim_path .. '.local'
endif

function! EditRcFilesV2() abort
  " let fm = [s:vimrc_path, s:extra_vimrc_path, g:init_vim_path, g:extra_init_vim_path, g:config_lua_path, g:coc_settings_json_path]
  let fm = [s:vimrc_path, s:extra_vimrc_path, g:init_lua_path, g:coc_settings_json_path]
  let n = confirm("To edit:", "&1vimrc\n&2vimrc.local\n&3init.lua\n&4coc.json")
  if n == 0
    return
  endif
  if winnr() == 1 && &ft =~ '\v^(alpha|startify)$'
    execute 'silent e ' .. fm[n-1]
  else
    execute 'silent vsplit ' .. fm[n-1]
  endif
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
  let &background = &background ==? 'dark'? 'light': 'dark'

  execute 'colorscheme ' . cs
  echom "Color: " . cs . " Background: " . &background
endfunction

" let background fit the clock
function! LetBgFitClock()
  let &background = s:bg_light? 'light': 'dark'
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
  let curline = getline(a:lnum)
  if curline == ''
    " check if inside func/aug
    return '0'
  elseif curline =~? '\v^\s*$'
    return '-1'
  elseif curline =~? '\v^"\s+(-{44}|\/\*).*$'
    return '0'
  elseif curline =~? '\v^\s*".*$'
    if a:lnum > 0 && (getline(a:lnum + 1) =~? '\v^\s*(".*)?$' || getline(a:lnum - 1) =~? '\v^\s*"')
      return '3'
    else
      return '1'
    endif
  elseif curline =~? '\v^(augroup|function).*$'
    return '1'
  elseif curline =~? '\v\S'
    return '2'
  else
    return '0'
  endif
endfunction

function! MyFoldText()
  let nl = v:foldend - v:foldstart + 1
  let linetext = getline(v:foldstart)
  let left = substitute(linetext, '\t', repeat(' ', &tabstop), "g")
  let txt = substitute(left, '^  ', '+ ', 1) .. ' ...     [' .. nl .. ' lines] '
  return txt
endfunction
set foldtext=MyFoldText()


" au when change colo
augroup fit_colorscheme
  au!
  if v:version >= 801 || has('nvim')
    au ColorSchemePre * call BeforeChangeColorscheme()
    au ColorSchemePre atomic,NeoSolarized,ayu,palenight,sacredforest call SetTermguiColors('yes')
  endif
  au ColorScheme * call AfterChangeColorscheme()
  " au ColorScheme github_light,blue-moon,github_light_default,github_* set nocursorcolumn
  au ColorScheme blue-moon,github_* set nocursorcolumn
augroup END

function! s:GetFitAirlineTheme(cname)
  if a:cname =~ '\v^(default|blackbeauty)' | return '' | endif

  let airline_theme = a:cname
  let m = { 'NeoSolarized': 'solarized', 'atomic': 'atomic', 'github': 'minimalist', 'seoul256': 'seoul256' }
  if has_key(m, a:cname)
    let airline_theme = m[a:cname]
  elseif a:cname ==? 'gruvbox'
    let airline_theme = s:bg_light? 'base16_gruvbox_light_soft': 'base16_gruvbox_dark_hard'
  endif
  return airline_theme
endfunction

function! s:DisableAirline()
  let g:airline#extensions#tabline#enabled = 0
  let g:airline_disable_statusline = 1
endfunction

function! SetColorScheme(cname) abort
  if exists('g:colors_name')
    return
  endif
  " fake cs pre
  let s:cname = a:cname
  if s:bg_light
    if a:cname == 'seoul256'
      let s:cname = 'seoul256-light'
    elseif a:cname == 'atomic'
      let g:atomic_mode = 9  " light soft
    endif
  endif
  execute 'colorscheme ' . s:cname

  if g:line_plugin == 'airline'
    " Fit airline or disable it
    let airline_theme = s:GetFitAirlineTheme(s:cname)
    if airline_theme == '' || index(airline#util#themes(''), airline_theme) == -1
      call s:DisableAirline()
    else
      let g:airline_theme = airline_theme
    endif
  endif
endfunction

function! RandomSetColo(themes)
  let choosen_colo = a:themes[rand() % len(a:themes)]
  call SetColorScheme(choosen_colo)
endfunction


" --------------------------------------------
" compatible with gui
" --------------------------------------------

if has('gui_running')
  set lines=77
  set columns=150

  set winaltkeys=no
  " lang
  set langmenu=en_US
  let $LANG = 'en_US.UTF-8'
  " window / tab / bar / ...
  set guioptions+=v
  " set guioptions+=e
  set guioptions+=i
  " set guioptions+=!
  set guioptions+=g
  set guioptions-=T
  set guioptions-=m
  set guioptions-=L
  set guioptions-=r
  set guioptions-=b
  set guioptions-=e
  set nolist
endif

" --------------------------------------------
" compatible with Windows
" --------------------------------------------

" gvim on win
if has("win32")
  source $VIMRUNTIME/delmenu.vim
  source $VIMRUNTIME/menu.vim
endif

" --------------------------------------------
" colorschemes
" --------------------------------------------

" /* for NeoSolarized */
let g:neosolarized_contrast = "high"
let g:neosolarized_visibility = "high"

" /* for vim-atomic */
" let g:atomic_mode = 3 " Cyan soft
let g:atomic_mode = 7  " night soft
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
if filereadable(s:extra_vimrc_path)
  execute 'source ' . s:extra_vimrc_path
endif

" command -nargs=1 Colo :call SetColorScheme('<args>')

" fallback
if !exists('g:colors_name') && !has('nvim')
  if !s:is_win
    call RandomSetColo([
          \'Tomorrow',
          \'1989',
          \'NeoSolarized',
          \'gruvbox',
          \'seoul256',
          \'bubblegum',
          \'darkburn',
          \'enigma',
          \'eva01',
          \'evening',
          \'apprentice',
          \'molokai',
          \])
  else
    call RandomSetColo([
          \'NeoSolarized',
          \'seoul256',
          \'atomic',
          \])
  endif
endif


" before nvim config .local
if s:is_win && !has('nvim')
  let &t_SI .= "\<Esc>[6 q"
  let &t_SR .= "\<Esc>[3 q"
  let &t_EI .= "\<Esc>[2 q"
endif

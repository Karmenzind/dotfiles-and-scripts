" Github: https://github.com/Karmenzind/dotfiles-and-scripts

" share the .vimrc with Vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" check extra init.vim.local
let g:init_vim_path = glob('~/.config/nvim/init.vim')
let g:extra_init_vim_path = g:init_vim_path . '.local'
let s:valid_extra_init_vim = filereadable(g:extra_init_vim_path)

" to specify the providers
let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'
let g:ruby_host_prog = trim(system("find $HOME/.gem -regex '.*ruby/[^/]+/bin/neovim-ruby-host'"))

" language server
let g:LanguageClient_serverCommands = {
      \ 'vue': ['vls']
      \ }

if s:valid_extra_init_vim
  execute 'source ' . g:extra_init_vim_path
endif

set termguicolors
lua require'colorizer'.setup()

" terminal
" --------------------------------------------

" XXX: <2019-11-28> 会导致fzf异常
" tnoremap <Esc> <C-\><C-n>
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

noremap <Leader>T  :sp<CR>:terminal<CR>A

" fzf
" --------------------------------------------

" if has('nvim')
"   let $FZF_DEFAULT_OPTS .= ' --layout=reverse'

"   function! FloatingFZF()
"     let buf = nvim_create_buf(v:false, v:true)

"     " here be dragoons
"     let wh = &lines " window height
"     let ww = &columns " window width
"     let g = 0.618
"     " let col_offset = float2nr(&columns / 10)
"     let opts = {
"           \ 'relative': 'editor',
"           \ 'row': float2nr(wh * (1 - g)),
"           \ 'col': float2nr(ww * pow((1 - g), 3)),
"           \ 'width': float2nr(ww * g),
"           \ 'height': float2nr(wh * g),
"           \ 'style': 'minimal',
"           \ }

"     let win = nvim_open_win(buf, v:true, opts)
"     " uncomment this if you want a normal background color for the fzf window
"     " call setwinvar(win, '&winhighlight', 'NormalFloat:Normal')
"     call setwinvar(win, '&winhl', 'NormalFloat:TabLine')

"     " this is to remove all line numbers and so on from the window
"     setlocal
"           \ buftype=nofile
"           \ bufhidden=hide
"           \ nonumber
"           \ norelativenumber
"           \ signcolumn=no
"   endfunction

"   let g:fzf_layout = { 'window': 'call FloatingFZF()' }
" endif

" highlight NormalFloat cterm=NONE ctermfg=14 ctermbg=0 gui=NONE guifg=#93a1a1 guibg=#002931

" Github: https://github.com/Karmenzind/dotfiles-and-scripts

" share the .vimrc with Vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" to specify the providers
let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'
let g:ruby_host_prog = trim(system("find $HOME/.gem -regex '.*ruby/[^/]+/bin/neovim-ruby-host'"))

if filereadable(g:extra_init_vim_path)
  execute 'source ' . g:extra_init_vim_path
endif

set termguicolors

" terminal
" --------------------------------------------

" XXX: <2019-11-28> 会导致fzf异常
function! s:TEsc() abort
  if &ft == 'fzf'
    normal 
  else
    normal 
  endif
endfunction


function! s:BindEsc() abort
  if &ft == 'fzf'
    echom "bingo"
    return
  else
    echom &ft
    tnoremap <buffer> <Esc> <C-\><C-n>
  endif
endfunction

augroup fzfSpecs
  autocmd! FileType fzf
  autocmd BufEnter * call s:BindEsc()
  autocmd  FileType fzf set laststatus=0 noshowmode noruler |
        \ autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END


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

" nnoremap <silent> <leader>g :split \| lua vim.lsp.buf.definition({reuse_win = true})<CR>
" nnoremap <silent> <leader>g :lua vim.lsp.buf.definition({reuse_win = true})<CR>

set completeopt=menu,menuone,noselect

lua require('config')

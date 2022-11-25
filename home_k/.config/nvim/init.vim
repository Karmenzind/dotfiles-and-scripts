" Github: https://github.com/Karmenzind/dotfiles-and-scripts

let s:is_win = has("win32")

" share the .vimrc with Vim

" to specify the providers
if !s:is_win
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc

  let g:python_host_prog = '/usr/bin/python2'
  let g:python3_host_prog = '/usr/bin/python3'
  let g:ruby_host_prog = trim(system("find $HOME/.gem -regex '.*ruby/[^/]+/bin/neovim-ruby-host'"))
else
  set runtimepath^=~/vimfiles runtimepath+=~/vimfiles/after
  let &packpath = &runtimepath
  source ~/_vimrc
endif

if filereadable(g:extra_init_vim_path)
  execute 'source ' . g:extra_init_vim_path
endif

set termguicolors

" terminal
" --------------------------------------------
function! s:TermEsc() abort
  if &ft =~ '\v^(fzf|Telescope)'
    execute("close")
  else
    call feedkeys("")
    return
  endif
endfunction

function! s:LazyEsc() abort
  tnoremap <buffer> <Esc> <cmd>call <SID>TermEsc()<CR>
endfunction

augroup fzfSpecs
  autocmd! FileType fzf
  autocmd BufEnter * call s:LazyEsc()
  autocmd  FileType fzf set laststatus=0 noshowmode noruler |
        \ autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END

" nnoremap <leader>ca :CodeActionMenu<cr>
" vnoremap <leader>ca :'<,'>CodeActionMenu<cr>
" xnoremap <leader>ca :'<,'>CodeActionMenu<cr>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>


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

" noremap <Leader>T  :sp<CR>:terminal<CR>A

" nnoremap <silent> <leader>g :split \| lua vim.lsp.buf.definition({reuse_win = true})<CR>
" nnoremap <silent> <leader>g :lua vim.lsp.buf.definition({reuse_win = true})<CR>

set completeopt=menu,menuone,noselect

lua require('config')

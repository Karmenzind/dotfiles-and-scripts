" vim:set et sw=2 ts=2 tw=78 ft=vim:
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

" /* telescope */
nnoremap <leader>tf <cmd>Telescope find_files<cr>
nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

" /* dap */
nnoremap <silent> <leader>db <cmd>lua require'dap'.toggle_breakpoint()<cr>
nnoremap <silent> <Leader>dc <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
" nnoremap <leader>dc <cmd>lua require'dap'.continue()<cr>
" nnoremap <leader>dso <cmd>lua require'dap'.step_over()<cr>
" nnoremap <leader>dsi <cmd>lua require'dap'.step_into()<cr>
" nnoremap <leader>dr <cmd>lua require'dap'.repl.open()<cr>
nnoremap <leader>dr <cmd>lua require'dapui'.float_element('repl')<cr>
nnoremap <leader>du <cmd>lua require'dapui'.toggle({reset=true})<cr>
nnoremap <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
" nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
" nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
" nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>

" lua tree
nnoremap <silent> <leader>N :NvimTreeFindFile<CR>
nnoremap <silent> <Leader>n :NvimTreeToggle<CR>

" --------------------------------------------
" colorschemes
" --------------------------------------------
let g:boo_colorscheme_theme = 'crimson_moonlight'

if !exists('g:colors_name')
  call RandomSetColo([
        \'NeoSolarized',
        \'blue-moon',
        \'atomic',
        \'boo',
        \'gruvbox',
        \'github_dark_high_contrast',
        \'github_light_high_contrast',
        \'nord',
        \'kat.nvim',
        \'kat.nwim',
        \'bluloco',
        \'tokyonight-night',
        \'tokyonight-storm',
        \'tokyonight-day',
        \'tokyonight-moon',
        \])
endif

lua require('config')


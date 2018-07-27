" Github: https://github.com/Karmenzind/dotfiles-and-scripts

" share the .vimrc with Vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" duel open .vimrc and init.vim
noremap <Leader>e  :tabe ~/.vimrc<CR>:vsp ~/.config/nvim/init.vim<CR>

" to specify the providers
let g:python_host_prog  = '/usr/bin/python2'
let g:python3_host_prog = '/home/k/Envs/General_Py3/bin/python'
let g:ruby_host_prog = '/home/k/.gem/ruby/2.5.0/bin/neovim-ruby-host'

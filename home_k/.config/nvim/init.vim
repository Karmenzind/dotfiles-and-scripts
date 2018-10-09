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
let g:ruby_host_prog = system("find $HOME/.gem -regex '.*ruby/[^/]+/bin/neovim-ruby-host'")

if s:valid_extra_init_vim
  execute 'source ' . g:extra_init_vim_path
endif

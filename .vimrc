set hlsearch

set bg=light

set noswapfile

set incsearch

set clipboard=unnamedplus
vnoremap <C-c> "+y

set tabstop=4
set softtabstop=4
set shiftwidth=4

set expandtab
set autoindent

set fileformat=unix

syntax on

set number relativenumber

autocmd BufEnter * execute "chdir ".escape(expand("%:p:h"), '')
autocmd BufWritePost "Xresources,*Xdefaults !xrdb %

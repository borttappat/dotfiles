set hlsearch

set bg=light

set noswapfile

set incsearch

set clipboard=unnamedplus
vnoremap <C-c> "+y

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set autoindent		" auto indentation
set incsearch		" incremental search
set nobackup		" no *~ backup files
set copyindent		" copy the previous indentation on autoindenting
set ignorecase		" ignore case when searching
set smartcase		" ignore case if search pattern is all lowercase,case-sensitive otherwise
set smarttab		" insert tabs on the start of a line according to context
set fileformat=unix

syntax on

set number relativenumber

autocmd BufEnter * execute "chdir ".escape(expand("%:p:h"), '')
autocmd BufWritePost "Xresources,*Xdefaults !xrdb %

set hlsearch

set bg=light

set noswapfile

set clipboard=unnamed

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set scrolloff=10
set showcmd
set hlsearch
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

"Status line
" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%  

" Show the status on the second to last line.
set laststatus=2


set autoindent		" auto indentation
set incsearch		" incremental search
set nobackup		" no *~ backup files
set copyindent		" copy the previous indentation on autoindenting
set ignorecase		" ignore case when searching
set smartcase		" ignore case if search pattern is all lowercase,case-sensitive otherwise
set smarttab		" insert tabs on the start of a line according to context
set fileformat=unix
set ruler

syntax on

set number relativenumber

autocmd BufEnter * execute "chdir ".escape(expand("%:p:h"), '')
autocmd BufWritePost "Xresources,*Xdefaults !xrdb %

set undofile
set clipboard=unnamedplus
set expandtab
set shiftwidth=4
set softtabstop=-1
syntax off | highlight Normal guifg=#a89983 guibg=#282828
nnoremap <space>y :let @+ = expand('%:p')<CR>
packadd comment | filetype plugin on

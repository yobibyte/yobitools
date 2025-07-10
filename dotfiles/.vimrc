set undofile
set clipboard=unnamedplus
set expandtab
set shiftwidth=4
set softtabstop=-1
syntax off | highlight Normal guifg=#a89983 guibg=#282828
nnoremap <space>y :let @+ = expand('%:p')<CR>
nnoremap <silent> <space>c :enew<Bar>setlocal buftype=nofile bufhidden=wipe<Bar>call feedkeys(":r !")<CR>
packadd comment | filetype plugin on

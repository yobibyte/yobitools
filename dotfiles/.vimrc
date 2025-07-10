set undofile
set clipboard=unnamedplus
set expandtab
set shiftwidth=4
set softtabstop=-1
syntax off | highlight Normal guifg=#ffaf00 guibg=#282828
packadd comment | filetype plugin on
nnoremap <space>y :let @+ = expand('%:p')<CR>
nnoremap <silent> <space>c :enew<Bar>setlocal buftype=nofile bufhidden=wipe<Bar>call feedkeys(":r !")<CR>
function FindRipGrepFiles(arg, _)
  return filter(systemlist('rg --files'), 'v:val =~? a:arg')
endfunction
set findfunc=FindRipGrepFiles

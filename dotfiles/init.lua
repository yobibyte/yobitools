vim.o.undofile      = true
vim.o.clipboard     = "unnamedplus"
vim.o.laststatus    = 0
vim.opt.expandtab   = true
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = -1
vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#ffaf00 guibg=#282828")
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.cmd("noswapfile enew | setlocal buftype=nofile bufhidden=wipe | call feedkeys(':read !', 'n')") end)

vim.o.undofile = true
vim.opt.expandtab = true
vim.o.clipboard = "unnamedplus"
vim.o.laststatus = 0
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.cmd("syntax off | highlight Normal guibg=#282828 guifg=#a89983")
vim.api.nvim_create_autocmd("BufEnter", {callback = function() vim.treesitter.stop() end})
vim.keymap.set('n', '<space>y', "<cmd>let @+ = expand('%:p')<CR>")
vim.keymap.set("n", "<space>c", function() vim.cmd("nos ene | setl bt=nofile bh=wipe") vim.cmd("r !" .. vim.fn.input("")) vim.cmd("1d") end)
